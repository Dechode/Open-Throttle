class_name BaseCar
extends RigidBody3D


######## CONSTANTS ########
const PETROL_KG_L: float = 0.7489
const NM_2_KW: int = 9549
const AV_2_RPM: float = 60 / TAU

@export var car_params: CarParameters

######### inputs #########
var throttle_input: float = 0.0
var steering_input: float = 0.0
var brake_input: float = 0.0
var handbrake_input: float = 0.0
var clutch_input: float = 0.0

######### Misc #########
var air_density = 1.225

var clutch_reaction_torque = 0.0
var drive_reaction_torque = 0.0

var fuel: float = 0.0
#var torque_out: float = 0.0
var rpm: float = 0.0

var rear_brake_torque: float = 0.0
var front_brake_torque: float = 0.0

var selected_gear: int = 0

var speedo: float = 0.0

var susp_comp: Array = [0.5, 0.5, 0.5, 0.5]

var avg_rear_spin = 0.0
var avg_front_spin = 0.0

var front_split := 0.5
var rear_split := 0.5

var local_vel: Vector3 = Vector3.ZERO
var prev_pos: Vector3 = Vector3.ZERO

var last_shift_time = 0

######### Instances ######### 
var clutch: Clutch
var drivetrain: DriveTrain
var driver: Driver

@onready var wheel_fl = $Wheel_fl as RaycastSuspension
@onready var wheel_fr = $Wheel_fr as RaycastSuspension
@onready var wheel_bl = $Wheel_bl as RaycastSuspension
@onready var wheel_br = $Wheel_br as RaycastSuspension
@onready var audioplayer = $EngineSound


func _init() -> void:
	clutch = Clutch.new()
	drivetrain = DriveTrain.new()
	car_params = CarParameters.new()
	driver = Driver.new()


func _ready() -> void:
	fuel = car_params.fuel_tank_size * car_params.fuel_percentage * 0.01
	self.mass += fuel * PETROL_KG_L
	
	clutch.friction = car_params.clutch_friction

	drivetrain.rear_diff = car_params.rear_diff
	drivetrain.front_diff = car_params.front_diff
	drivetrain.gear_inertia = car_params.gear_inertia
	drivetrain.gear_ratios = car_params.gear_ratios
	drivetrain.reverse_ratio = car_params.reverse_ratio
	drivetrain.final_drive = car_params.final_drive
	drivetrain.front_diff_power_ratio = car_params.front_diff_power_ratio
	drivetrain.rear_diff_power_ratio = car_params.rear_diff_power_ratio
	drivetrain.front_diff_coast_ratio = car_params.front_diff_coast_ratio
	drivetrain.rear_diff_coast_ratio = car_params.rear_diff_coast_ratio
	drivetrain.automatic = car_params.automatic
	drivetrain.drivetype = car_params.drivetype
	drivetrain.transmission_efficiency = car_params.transmission_efficiency
	drivetrain.set_front_diff_preload(car_params.front_diff_preload)
	drivetrain.set_rear_diff_preload(car_params.rear_diff_preload)
	drivetrain.set_input_inertia(car_params.engine_moment)
	
	add_child(clutch)
	add_child(drivetrain)
	
	wheel_fl.set_params(car_params.wheel_params_fl)
	wheel_fr.set_params(car_params.wheel_params_fr)
	wheel_bl.set_params(car_params.wheel_params_bl)
	wheel_br.set_params(car_params.wheel_params_br)
	
	play_engine_sound()


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
	
	##### Anti-Roll Bar #####
	var prev_comp = susp_comp
	susp_comp[0] = wheel_bl.apply_forces(prev_comp[1], delta)
	susp_comp[1] = wheel_br.apply_forces(prev_comp[0], delta)
	susp_comp[2] = wheel_fr.apply_forces(prev_comp[3], delta)
	susp_comp[3] = wheel_fl.apply_forces(prev_comp[2], delta)
	
	wheel_fl.steer(steering_input, car_params.max_steer)
	wheel_fr.steer(steering_input, car_params.max_steer)
	
	var torque_out = engine_loop(delta)
	
	if selected_gear == 0:
		freewheel(delta)
	else:
		engage(delta)
	
	if car_params.automatic:
		automatic_shifting_logic(torque_out)
	apply_drag_force()
	
	self.linear_damp = 0.0
	if abs(local_vel.z) < 2.0:
		self.linear_damp = 1.0
	


func set_driver(new_driver):
	driver.queue_free()
	driver = new_driver
	add_child(driver)


func automatic_shifting_logic(torque_out):
	var reversing = false
	var shift_time = 700
	var next_gear_rpm = 0
	if selected_gear < car_params.gear_ratios.size():
		next_gear_rpm = drivetrain.gear_ratios[selected_gear] * drivetrain.final_drive * avg_front_spin * AV_2_RPM
	
	var prev_gear_rpm = 0
	if selected_gear - 1 > 0:
		prev_gear_rpm = drivetrain.gear_ratios[selected_gear - 1] * drivetrain.final_drive * avg_front_spin * AV_2_RPM
	
	if selected_gear == -1:
		reversing = true

	var torque_bigger_next_gear = get_engine_torgue(next_gear_rpm) > torque_out# - drag_torque
	if torque_bigger_next_gear and selected_gear >= 0:
		if rpm > 0.85 * car_params.max_engine_rpm:
			if Time.get_ticks_msec() - last_shift_time > shift_time:
				shift_up()
	var torque_bigger_prev_gear = get_engine_torgue(prev_gear_rpm) > torque_out# - drag_torque
	if selected_gear > 1 and rpm < 0.5 * car_params.max_engine_rpm and torque_bigger_prev_gear:
		if Time.get_ticks_msec() - last_shift_time > shift_time:
			shift_down()
	if abs(selected_gear) <= 1 and abs(local_vel.z) < 3.0 and brake_input > 0.2:
		if not reversing:
			if Time.get_ticks_msec() - last_shift_time > shift_time:
				shift_down()
		else:
			if Time.get_ticks_msec() - last_shift_time > shift_time:
				shift_up()


func engine_loop(delta):
	var drag_torque = car_params.engine_brake + rpm * car_params.engine_drag
	var torque_out = (get_engine_torgue(rpm) + drag_torque ) * throttle_input
	var engine_net_torque = torque_out + clutch_reaction_torque - drag_torque
	rpm += AV_2_RPM * delta * engine_net_torque / car_params.engine_moment
	if rpm >= car_params.max_engine_rpm:
		torque_out = 0.0
		rpm -= 500.0
	if rpm <= (car_params.rpm_idle + 10) and abs(local_vel.z) <= 5:
		clutch_input = 1.0
#	play_engine_sound()
	update_engine_sound()
	if fuel <= 0.0:
		torque_out = 0.0
		rpm = 0.0
		stop_engine_sound()
	burn_fuel(torque_out, delta)
	rpm = max(rpm , car_params.rpm_idle)
#	rpm = max(rpm , 0) # TODO make engine able to shutoff?
	return torque_out


func get_engine_torgue(p_rpm) -> float: 
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
	if drivetrain.drivetype == drivetrain.DRIVE_TYPE.RWD:
		gearbox_av = avg_rear_spin * drivetrain.get_gearing() 
	elif drivetrain.drivetype == drivetrain.DRIVE_TYPE.FWD:
		gearbox_av = avg_front_spin * drivetrain.get_gearing()
	elif drivetrain.drivetype == drivetrain.DRIVE_TYPE.AWD:
		gearbox_av = (avg_front_spin + avg_rear_spin) * 0.5 * drivetrain.get_gearing()
	
	var delta_av := engine_av - gearbox_av
	var clutch_kick: float = abs(delta_av) * 0.2
	var reaction_torques = clutch.get_reaction_torques(engine_av, gearbox_av, clutch_input, clutch_kick)
	drive_reaction_torque = reaction_torques.x
	clutch_reaction_torque = reaction_torques.y
	
	drivetrain.drivetrain(drive_reaction_torque, rear_brake_torque, front_brake_torque, [wheel_bl, wheel_br, wheel_fl, wheel_fr], delta)
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
	if selected_gear < drivetrain.gear_ratios.size():
		selected_gear += 1
		last_shift_time = Time.get_ticks_msec()
		drivetrain.set_selected_gear(selected_gear)


func shift_down():
	if selected_gear > -1:
		selected_gear -= 1
		last_shift_time = Time.get_ticks_msec()
		drivetrain.set_selected_gear(selected_gear)


func play_engine_sound():
	if rpm >= car_params.rpm_idle and rpm < car_params.max_engine_rpm:
		if !audioplayer.playing:
			audioplayer.play()


func update_engine_sound():
	var pitch_scaler = rpm / 1000
	if pitch_scaler > 0.1:
		audioplayer.pitch_scale = pitch_scaler
	else:
		audioplayer.pitch_scale = 0.1


func stop_engine_sound():
	audioplayer.stop()
