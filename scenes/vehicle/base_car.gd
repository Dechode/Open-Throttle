class_name BaseCar
extends RigidBody3D

enum DIFF_TYPE{
	LIMITED_SLIP,
	OPEN_DIFF,
	LOCKED,
}

enum DIFF_STATE{
	LOCKED,
	SLIPPING,
	OPEN,
}

enum DRIVE_TYPE{
	FWD,
	RWD,
	AWD,
}

######## CONSTANTS ########
const PETROL_KG_L: float = 0.7489
const NM_2_KW: int = 9549
const AV_2_RPM: float = 60 / TAU

######## Export variables ######## 
@export var max_steer := 0.3
@export var front_brake_bias := 0.6
@export var steer_speed := 5.0
@export var max_brake_force := 5000.0
@export var fuel_tank_size := 40.0 # Liters
@export var fuel_percentage := 100.0 # % of full tank

######### Engine variables #########
@export var max_torque := 250.0
@export var max_engine_rpm := 8000.0
@export var rpm_idle := 900.0
@export var torque_curve: Curve = null
@export var engine_drag := 0.03
@export var engine_brake := 10.0
@export var engine_moment := 0.25
@export var engine_bsfc := 0.3
@export var engine_sound: AudioStreamPlayer
@export var clutch_friction := 500.0

######### Drivetrain variables #########
@export var drivetype := DRIVE_TYPE.RWD
@export var gear_ratios := [ 3.1, 2.61, 2.1, 1.72, 1.2, 1.0 ] 
@export var automatic := true
@export var final_drive := 3.7
@export var reverse_ratio := 3.9
@export var gear_inertia := 0.2
@export var transmission_efficiency := 0.9

@export var rear_diff := DIFF_TYPE.LIMITED_SLIP
@export var front_diff := DIFF_TYPE.LIMITED_SLIP

@export var rear_diff_preload := 50.0
@export var front_diff_preload := 50.0

@export var rear_diff_power_ratio := 2.0
@export var front_diff_power_ratio := 2.0

@export var rear_diff_coast_ratio := 1.0
@export var front_diff_coast_ratio := 1.0

@export var center_split_fr := 0.4 # AWD torque split front / rear

######### Aero #########
@export var cd := 0.3
@export var frontal_area := 2.0

######### Controller inputs #########
var throttle_input: float = 0.0
var steering_input: float = 0.0
var brake_input: float = 0.0
var handbrake_input: float = 0.0
var clutch_input: float = 0.0
#var steering_value := 0.0

######### Misc #########
var air_density = 1.225

var clutch_reaction_torque = 0.0
var drive_reaction_torque = 0.0

var fuel: float = 0.0
#var torque_out: float = 0.0
var rpm: float = 0.0

var rear_brake_force: float = 0.0
var front_brake_force: float = 0.0

var selected_gear: int = 0

var speedo: float = 0.0
var wheel_radius: float = 0.0
var susp_comp: Array = [0.5, 0.5, 0.5, 0.5]

var avg_rear_spin = 0.0
var avg_front_spin = 0.0

var front_split := 0.5
var rear_split := 0.5

var local_vel: Vector3 = Vector3.ZERO
var prev_pos: Vector3 = Vector3.ZERO

var last_shift_time = 0

@onready var wheel_fl = $Wheel_fl
@onready var wheel_fr = $Wheel_fr
@onready var wheel_bl = $Wheel_bl
@onready var wheel_br = $Wheel_br
@onready var rear_wheels := [wheel_bl,wheel_br]
@onready var front_wheels := [wheel_fl,wheel_fr]
@onready var audioplayer = $EngineSound


func _ready() -> void:
	wheel_radius = wheel_fl.tire_radius
	fuel = fuel_tank_size * fuel_percentage * 0.01
	self.mass += fuel * PETROL_KG_L


func _physics_process(delta):
	var rear_brake_input = max(brake_input, handbrake_input)
	front_brake_force = max_brake_force * brake_input * front_brake_bias
	rear_brake_force = max_brake_force * rear_brake_input * (1 - front_brake_bias)
	
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
	
	wheel_fl.steer(steering_input, max_steer)
	wheel_fr.steer(steering_input, max_steer)
	
	var torque_out = engine_loop(delta)
	
	if selected_gear == 0:
		freewheel(delta)
	else:
		engage(delta)
	
	if automatic:
		automatic_shifting_logic(torque_out)
	apply_drag_force()


func automatic_shifting_logic(torque_out):
	var reversing = false
	var shift_time = 700
	var next_gear_rpm = 0
	if selected_gear < gear_ratios.size():
		next_gear_rpm = gear_ratios[selected_gear] * final_drive * avg_front_spin * AV_2_RPM
	
	var prev_gear_rpm = 0
	if selected_gear - 1 > 0:
		prev_gear_rpm = gear_ratios[selected_gear - 1] * final_drive * avg_front_spin * AV_2_RPM
	
	if selected_gear == -1:
		reversing = true

	var torque_bigger_next_gear = get_engine_torgue(next_gear_rpm) > torque_out# - drag_torque
	if torque_bigger_next_gear and selected_gear >= 0:
		if rpm > 0.85 * max_engine_rpm:
			if Time.get_ticks_msec() - last_shift_time > shift_time:
				shift_up()
	var torque_bigger_prev_gear = get_engine_torgue(prev_gear_rpm) > torque_out# - drag_torque
	if selected_gear > 1 and rpm < 0.5 * max_engine_rpm and torque_bigger_prev_gear:
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
	var drag_torque = engine_brake + rpm * engine_drag
	var torque_out = (get_engine_torgue(rpm) + drag_torque ) * throttle_input
	var engine_net_torque = torque_out + clutch_reaction_torque - drag_torque
	rpm += AV_2_RPM * delta * engine_net_torque / engine_moment
	if rpm >= max_engine_rpm:
		torque_out = 0.0
		rpm -= 500.0
	if rpm <= (rpm_idle + 10) and abs(local_vel.z) <= 2:
		clutch_input = 1.0
	play_engine_sound()
	if fuel <= 0.0:
		torque_out = 0.0
		rpm = 0.0
		stop_engine_sound()
	burn_fuel(torque_out, delta)
	rpm = max(rpm , rpm_idle)
	return torque_out


func get_engine_torgue(p_rpm) -> float: 
	var rpm_factor = clamp(p_rpm / max_engine_rpm, 0.0, 1.0)
	var torque_factor = torque_curve.sample_baked(rpm_factor)
	return torque_factor * max_torque


func freewheel(delta):
	clutch_reaction_torque = 0.0
	drive_reaction_torque = 0.0
	avg_front_spin = 0.0
	avg_front_spin = 0.0
	wheel_bl.apply_torque(0.0, 0.0, rear_brake_force * 0.5, delta)
	wheel_br.apply_torque(0.0, 0.0, rear_brake_force * 0.5, delta)
	wheel_fl.apply_torque(0.0, 0.0, front_brake_force * 0.5, delta)
	wheel_fr.apply_torque(0.0, 0.0, front_brake_force * 0.5, delta)
	avg_front_spin += (wheel_fl.get_spin() + wheel_fr.get_spin()) * 0.5
	speedo = avg_front_spin * wheel_radius * 3.6


func engage(delta):
	var gearbox_av: float
	avg_rear_spin = 0.0
	avg_front_spin = 0.0
	avg_rear_spin += (wheel_bl.get_spin() + wheel_br.get_spin()) * 0.5
	avg_front_spin += (wheel_fl.get_spin() + wheel_fr.get_spin()) * 0.5
	
	var engine_av = rpm / AV_2_RPM
	if drivetype == DRIVE_TYPE.RWD:
		gearbox_av = avg_rear_spin * get_gear_ratios() 
	elif drivetype == DRIVE_TYPE.FWD:
		gearbox_av = avg_front_spin * get_gear_ratios() 
	elif drivetype == DRIVE_TYPE.AWD:
		gearbox_av = (avg_front_spin + avg_rear_spin) * 0.5 * get_gear_ratios()
	
	var clutch_reactions = clutch(engine_av, gearbox_av, clutch_friction, clutch_input)
	clutch_reaction_torque = clutch_reactions[0]
	var net_drive = clutch_reactions[1] * get_gear_ratios() * transmission_efficiency
	drivetrain(net_drive, delta)
	speedo = avg_front_spin * wheel_radius * 3.6


func clutch(shaft_1_av, shaft_2_av, friction, _clutch_input = 0.0):
	var speed_error = shaft_1_av - shaft_2_av
	var clutch_kick = abs(speed_error) * 0.2
	clutch_kick = clamp(clutch_kick, 0 , 50)
	var clutch_torque: float = (friction + clutch_kick) * (1 - _clutch_input)
	var reaction_torques := [0.0, 0.0]
	if shaft_1_av > shaft_2_av:
		reaction_torques[0] = -clutch_torque
		reaction_torques[1] = clutch_torque
	else:
		reaction_torques[0] = clutch_torque
		reaction_torques[1] = -clutch_torque
	return reaction_torques


func drivetrain(drive_torque, delta):
	if drivetype == DRIVE_TYPE.RWD:
		rear_split = diff(rear_diff_preload, rear_diff_coast_ratio,
			rear_diff_power_ratio, rear_brake_force, 
			rear_diff, rear_wheels, 
			drive_torque, rear_split, delta)
		wheel_fl.apply_torque(0, 0, front_brake_force * 0.5, delta)
		wheel_fr.apply_torque(0, 0, front_brake_force * 0.5, delta)
		
	elif drivetype == DRIVE_TYPE.FWD:
		front_split = diff(front_diff_preload,front_diff_coast_ratio,
			front_diff_power_ratio, front_brake_force,  
			front_diff, front_wheels, 
			drive_torque,front_split, delta)
		wheel_bl.apply_torque(0, 0, rear_brake_force * 0.5, delta)
		wheel_br.apply_torque(0, 0, rear_brake_force * 0.5, delta)
		
	elif drivetype == DRIVE_TYPE.AWD:
		var rear_drive = drive_torque * (1 - center_split_fr)
		var front_drive = drive_torque * center_split_fr
		
		rear_split = diff(rear_diff_preload, rear_diff_coast_ratio,
			rear_diff_power_ratio, rear_brake_force,  
			rear_diff, rear_wheels, 
			rear_drive, rear_split, delta)
		
		front_split = diff(front_diff_preload,front_diff_coast_ratio,
			front_diff_power_ratio, front_brake_force,  
			front_diff, front_wheels, 
			front_drive,front_split, delta)


func diff(diff_preload, coast_ratio, power_ratio, 
		brake_force, diff_type, wheels,
		drive_torque, split, delta):
	
	var diff_state = DIFF_STATE.LOCKED
	
	var left_brake = brake_force * 0.5
	var right_brake = brake_force * 0.5
	
	var delta_torque = wheels[0].get_reaction_torque() - wheels[1].get_reaction_torque()
	var t1 = drive_torque * 0.5
	var t2 = drive_torque * 0.5
	var drive_inertia = engine_moment + pow(abs(get_gear_ratios()), 2) * gear_inertia
	
	var ratio = power_ratio
	if drive_torque * sign(get_gear_ratios()) < 0:
		ratio = coast_ratio
	
	if diff_type == DIFF_TYPE.OPEN_DIFF:
		diff_state = DIFF_STATE.OPEN
	elif diff_type == DIFF_TYPE.LOCKED:
		diff_state = DIFF_STATE.LOCKED
	else:
		if abs(delta_torque) > diff_preload * ratio:
			diff_state = DIFF_STATE.SLIPPING
	
	match diff_state:
		DIFF_STATE.OPEN: # TODO Feels very slow, cant rev 4th gear to end
			var diff_sum := 0.0
			diff_sum += wheels[0].apply_torque(t1 * split, drive_inertia, left_brake, delta)
			diff_sum -= wheels[1].apply_torque(t2 * (1 - split), drive_inertia, right_brake, delta)
	
			return 0.5 * (clamp(diff_sum, -1.0, 1.0) + 1.0)
		
		DIFF_STATE.SLIPPING:
			var diff_torques = clutch(wheels[0].get_spin(), wheels[1].get_spin(), diff_preload)
			t1 += diff_torques[0]
			t2 += diff_torques[1]
			
			wheels[0].apply_torque(t1, drive_inertia, left_brake, delta)
			wheels[1].apply_torque(t2, drive_inertia, right_brake, delta)
			
			return 0.5
		
		DIFF_STATE.LOCKED:
			var net_torque = wheels[0].get_reaction_torque() + wheels[1].get_reaction_torque()
			net_torque += t1 + t2
			var spin: float
			var avg_spin = (wheels[0].get_spin() + wheels[1].get_spin()) * 0.5
			if abs(avg_spin) < 5.0 and brake_force > abs(t1 + t2):
				spin = 0.0
			else:
				var rolling_resistance = wheels[0].rolling_resistance + wheels[1].rolling_resistance
				net_torque -= (brake_force + rolling_resistance) * sign(avg_spin)
				spin = avg_spin + (delta * net_torque / (wheels[0].wheel_moment + drive_inertia + wheels[1].wheel_moment))
				wheels[0].set_spin(spin)
				wheels[1].set_spin(spin)
				
			return 0.5


func get_gear_ratios():
	if selected_gear > 0:
		return gear_ratios[selected_gear - 1] * final_drive
	elif selected_gear == -1:
		return -reverse_ratio * final_drive
	else:
		return 0.0


func apply_drag_force():
	var vel2 = local_vel.length_squared()
	var drag_force = 0.5 * vel2 * cd * frontal_area * air_density
	drag_force = clamp(drag_force, -10000, 10000)
	var drag_force_vec = drag_force * global_transform.basis.z # Positive because negative is forward
	apply_central_force(drag_force_vec)


func burn_fuel(torque ,delta):
	var fuel_burned = engine_bsfc * torque * rpm * delta / (3600 * PETROL_KG_L * NM_2_KW)
	fuel -= fuel_burned
	self.mass -= fuel_burned * PETROL_KG_L


func shift_up():
	if selected_gear < gear_ratios.size():
		selected_gear += 1
		last_shift_time = Time.get_ticks_msec()


func shift_down():
	if selected_gear > -1:
		selected_gear -= 1
		last_shift_time = Time.get_ticks_msec()


func play_engine_sound():
	var pitch_scaler = rpm / 1000
	if rpm >= rpm_idle and rpm < max_engine_rpm:

		if !audioplayer.playing:
			audioplayer.play()
	
	if pitch_scaler > 0.1:
		audioplayer.pitch_scale = pitch_scaler


func stop_engine_sound():
	audioplayer.stop()
