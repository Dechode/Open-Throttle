class_name BaseCar
extends RigidBody3D


######## CONSTANTS ########
const PETROL_KG_L: float = 0.7489
const NM_2_KW: int = 9549
const AV_2_RPM: float = 60 / TAU

@export var car_params := CarParameters.new()

######### inputs #########
var throttle_input: float = 0.0
var steering_input: float = 0.0
var brake_input: float = 0.0
var handbrake_input: float = 0.0
var clutch_input: float = 0.0

######### Signals #########
signal on_gear_change(gear: int)

######### Misc #########
var air_density = 1.225

var clutch_reaction_torque = 0.0
var drive_reaction_torque = 0.0

var fuel: float = 0.0
#var torque_out: float = 0.0
var rpm: float = 0.0

var rear_brake_torque: float = 0.0
var front_brake_torque: float = 0.0

#var selected_gear: int = 0

var speedo: float = 0.0

var susp_comp: Array = [0.5, 0.5, 0.5, 0.5]

var avg_rear_spin = 0.0
var avg_front_spin = 0.0


var local_vel: Vector3 = Vector3.ZERO
var prev_pos: Vector3 = Vector3.ZERO


######### Instances ######### 
var clutch: Clutch
var drivetrain: DriveTrain
var driver: Driver
var taillights: TailLights
var headlights: HeadLights

@onready var wheel_fl = $Wheel_fl as RaycastSuspension
@onready var wheel_fr = $Wheel_fr as RaycastSuspension
@onready var wheel_bl = $Wheel_bl as RaycastSuspension
@onready var wheel_br = $Wheel_br as RaycastSuspension


func _init() -> void:
	clutch = Clutch.new()
	drivetrain = DriveTrain.new()
	car_params = CarParameters.new()
	driver = Driver.new()


func _ready() -> void:
	fuel = car_params.fuel_tank_size * car_params.fuel_percentage * 0.01
	self.mass += fuel * PETROL_KG_L
	
	clutch.friction = car_params.clutch_friction
	
	drivetrain.drivetrain_params = car_params.drivetrain_params
	drivetrain.set_input_inertia(car_params.engine_moment)
	
	add_child(clutch)
	add_child(drivetrain)
	
	car_params.wheel_params_fl.ackermann = car_params.ackermann
	car_params.wheel_params_fr.ackermann = -car_params.ackermann
	
	wheel_fl.set_params(car_params.wheel_params_fl.duplicate(true))
	wheel_fr.set_params(car_params.wheel_params_fr.duplicate(true))
	wheel_bl.set_params(car_params.wheel_params_bl.duplicate(true))
	wheel_br.set_params(car_params.wheel_params_br.duplicate(true))
	
	taillights = get_node("TailLights") #as TailLights
	headlights = get_node("HeadLights") #as HeadLights
#	print(taillights)
	assert(taillights)
	assert(headlights)


func _physics_process(delta):
	steering_input = driver.steering_input
	throttle_input = driver.throttle_input
	brake_input = driver.brake_input
	handbrake_input = driver.handbrake_input
	clutch_input = driver.clutch_input
	
	var handbrake_torque = handbrake_input * car_params.max_handbrake_force
	var brake_torques = get_brake_torques(brake_input)
	front_brake_torque = brake_torques.x
	rear_brake_torque = max(brake_torques.y, handbrake_torque)
	
	local_vel = (global_transform.origin - prev_pos) / delta * global_transform.basis
	local_vel.z = clamp(local_vel.z, -1000, 1000)
	local_vel.x = clamp(local_vel.x, -1000, 1000)
	local_vel.y = clamp(local_vel.y, -1000, 1000)
	prev_pos = global_transform.origin
	
	
	wheel_fl.steer(steering_input, car_params.max_steer)
	wheel_fr.steer(steering_input, car_params.max_steer)
	
	var torque_out = engine_loop(delta)
	
	if drivetrain.selected_gear == 0:
		freewheel(delta)
	else:
		engage(delta)
	
	if car_params.drivetrain_params.automatic:
		var next_gear_rpm = 0
		if drivetrain.selected_gear < car_params.drivetrain_params.gear_ratios.size():
			next_gear_rpm = car_params.drivetrain_params.gear_ratios[drivetrain.selected_gear] * car_params.drivetrain_params.final_drive * avg_front_spin * AV_2_RPM

		var prev_gear_rpm = 0
		if drivetrain.selected_gear - 1 > 0:
			prev_gear_rpm = car_params.drivetrain_params.gear_ratios[drivetrain.selected_gear - 1] * car_params.drivetrain_params.final_drive * avg_front_spin * AV_2_RPM
		
		var next_gear_torque := get_engine_torque(next_gear_rpm)
		var prev_gear_torque := get_engine_torque(prev_gear_rpm)
		
		drivetrain.automatic_shifting(torque_out - clutch_reaction_torque, prev_gear_torque,
									next_gear_torque, rpm, car_params.max_engine_rpm,
									brake_input, local_vel.z)
	
	apply_drag_force()
	
	self.linear_damp = 0.0
	if abs(local_vel.z) < 2.0:
		self.linear_damp = 1.0
	
	##### Anti-Roll Bar and Apply Forces #####
	var prev_comp = susp_comp
	susp_comp[0] = wheel_bl.apply_forces(prev_comp[1], delta)
	susp_comp[1] = wheel_br.apply_forces(prev_comp[0], delta)
	susp_comp[2] = wheel_fr.apply_forces(prev_comp[3], delta)
	susp_comp[3] = wheel_fl.apply_forces(prev_comp[2], delta)


func set_driver(new_driver):
	driver.queue_free()
	driver = new_driver
	add_child(driver)


func engine_loop(delta):
	var drag_torque = car_params.engine_brake + rpm * car_params.engine_drag
	var torque_out = (get_engine_torque(rpm) + drag_torque ) * throttle_input
	var engine_net_torque = torque_out + clutch_reaction_torque - drag_torque
	rpm += AV_2_RPM * delta * engine_net_torque / car_params.engine_moment
	
	if rpm >= car_params.max_engine_rpm:
		torque_out = 0.0
		rpm -= 500.0
		
	if rpm <= (car_params.rpm_idle + 10) and abs(local_vel.z) <= 5 and throttle_input <= 0.1:
		clutch_input = 1.0
	
	
	if fuel <= 0.0:
		torque_out = 0.0
		rpm = 0.0
	
	burn_fuel(torque_out, delta)
	rpm = max(rpm , car_params.rpm_idle)
#	rpm = max(rpm , 0) # TODO make engine able to shutoff?
	return torque_out


func get_engine_torque(p_rpm) -> float: 
	var rpm_factor = clamp(p_rpm / car_params.max_engine_rpm, 0.0, 1.0)
	var torque_factor = car_params.torque_curve.sample_baked(rpm_factor)
	return torque_factor * car_params.max_torque


func get_brake_torques(p_brake_input: float):
	var clamping_force := p_brake_input * car_params.max_brake_force * 0.5 
	var brake_pad_mu := 0.4
	var braking_force := 2.0 * brake_pad_mu * clamping_force
	
	var torques := Vector2.ZERO
	
	torques.x = braking_force * car_params.brake_effective_radius * car_params.front_brake_bias
	torques.y = braking_force * car_params.brake_effective_radius * (1 - car_params.front_brake_bias)
	return torques


func freewheel(delta):
	clutch_reaction_torque = 0.0
	drive_reaction_torque = 0.0
	avg_front_spin = 0.0
	avg_front_spin = 0.0
	wheel_bl.apply_torque(0.0, rear_brake_torque * 0.5, 0.0, delta)
	wheel_br.apply_torque(0.0, rear_brake_torque * 0.5, 0.0, delta)
	wheel_fl.apply_torque(0.0, front_brake_torque * 0.5, 0.0, delta)
	wheel_fr.apply_torque(0.0, front_brake_torque * 0.5, 0.0, delta)
	avg_front_spin += (wheel_fl.get_spin() + wheel_fr.get_spin()) * 0.5
	speedo = avg_front_spin * wheel_fl.tire_radius * 3.6


func engage(delta):
	var gearbox_av: float
	avg_rear_spin = 0.0
	avg_front_spin = 0.0
	avg_rear_spin += (wheel_bl.get_spin() + wheel_br.get_spin()) * 0.5
	avg_front_spin += (wheel_fl.get_spin() + wheel_fr.get_spin()) * 0.5
	
	var engine_av := rpm / AV_2_RPM
	if drivetrain.drivetrain_params.drivetype == drivetrain.DRIVE_TYPE.RWD:
		gearbox_av = avg_rear_spin * drivetrain.get_gearing() 
	elif drivetrain.drivetrain_params.drivetype == drivetrain.DRIVE_TYPE.FWD:
		gearbox_av = avg_front_spin * drivetrain.get_gearing()
	elif drivetrain.drivetrain_params.drivetype == drivetrain.DRIVE_TYPE.AWD:
		gearbox_av = (avg_front_spin + avg_rear_spin) * 0.5 * drivetrain.get_gearing()
	
	var delta_av := engine_av - gearbox_av
	var clutch_kick: float = abs(delta_av) * 0.2
	var reaction_torques = clutch.get_reaction_torques(engine_av, gearbox_av, clutch_input, clutch_kick)
	drive_reaction_torque = reaction_torques.x
	clutch_reaction_torque = reaction_torques.y
	
	drivetrain.drivetrain(drive_reaction_torque, rear_brake_torque, front_brake_torque,
						[wheel_bl, wheel_br, wheel_fl, wheel_fr], clutch_input, delta)
	speedo = avg_front_spin * wheel_fl.tire_radius * 3.6


func apply_drag_force():
	var vel2 = local_vel.length_squared()
	var drag_force = 0.5 * vel2 * car_params.cd * car_params.frontal_area * car_params.air_density
	drag_force = clamp(drag_force, -10000, 10000)
	var drag_force_vec = drag_force * global_transform.basis.z # Positive because negative is forward
	apply_central_force(drag_force_vec)


func burn_fuel(torque, delta):
	var fuel_burned = car_params.engine_bsfc * torque * rpm * delta / (3600 * PETROL_KG_L * NM_2_KW)
	fuel -= fuel_burned
	self.mass -= fuel_burned * PETROL_KG_L


func shift_up():
	drivetrain.shift_up()
	on_gear_change.emit(drivetrain.selected_gear)


func shift_down():
	drivetrain.shift_down()
	on_gear_change.emit(drivetrain.selected_gear)


func get_self_aligning_torques() -> Vector2:
	# x is front wheels, y is rear wheels
	var vec := Vector2.ZERO
	vec.x = (wheel_fl.force_vec.z + wheel_fr.force_vec.z) * 0.5 #/ (self.mass * 0.1)
	vec.y = (wheel_bl.force_vec.z + wheel_br.force_vec.z) * 0.5 #/ (self.mass * 0.1)
	return vec
