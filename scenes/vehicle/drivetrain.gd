class_name DriveTrain
extends Node

enum DIFF_TYPE{
	LIMITED_SLIP,
	OPEN_DIFF,
	LOCKED,
}

enum DIFF_STATE {
	LOCKED,
	SLIPPING,
	OPEN,
}

enum DRIVE_TYPE{
	FWD,
	RWD,
	AWD,
}

#@export var drivetype = DRIVE_TYPE.RWD
#@export var gear_ratios = [ 3.1, 2.61, 2.1, 1.72, 1.2, 1.0 ] 
#@export var final_drive = 3.7
#@export var reverse_ratio = 3.9
#@export var gear_inertia = 0.10
#@export var automatic := true
#@export var transmission_efficiency := 0.9
#
#@export var rear_diff = DIFF_TYPE.LIMITED_SLIP
#@export var front_diff = DIFF_TYPE.LIMITED_SLIP
#
#@export var rear_diff_preload = 50.0
#@export var front_diff_preload = 50.0
#
#@export var rear_diff_power_ratio: float = 2.0
#@export var front_diff_power_ratio: float = 2.0
#
#@export var rear_diff_coast_ratio: float = 1.0
#@export var front_diff_coast_ratio: float = 1.0
#
#@export var center_split_fr = 0.4 # AWD torque split front / rear

@export var drivetrain_params := DriveTrainParameters.new()

var selected_gear := 0
var _diff_clutch := Clutch.new()
var _engine_inertia := 0.1
var _diff_split := 0.5
var last_shift_time := 0
var drive_inertia := 10.0

var avg_rear_spin := 0.0
var avg_front_spin := 0.0


#func _init():
#	_diff_clutch = Clutch.new()


#func _ready() -> void:
#	add_child(_diff_clutch)


#func set_rear_diff_preload(value):
#	rear_diff_preload = value

#func set_front_diff_preload(value):
#	front_diff_preload = value


#func set_selected_gear(gear):
#	gear = clamp(gear, -1, gear_ratios.size())
#	selected_gear = gear


#func get_gearing() -> float:
#	if selected_gear > gear_ratios.size():
#		return 0.0
#	if selected_gear > 0:
#		return gear_ratios[selected_gear - 1] * final_drive
#	if selected_gear == -1:
#		return -reverse_ratio * final_drive
#	return 0.0


#func set_input_inertia(value):
#	_engine_inertia =  value


#func differential(torque, brake_torque, wheels, diff_preload, power_ratio, coast_ratio, diff_type, clutch_input, delta: float):
	
#	print_debug(torque)
	
#	var delta_torque = wheels[0].get_reaction_torque() - wheels[1].get_reaction_torque()
#	var t1 = torque * 0.5 * transmission_efficiency
#	var t2 = torque * 0.5 * transmission_efficiency
#	var drive_inertia = (_engine_inertia + pow(abs(get_gearing()), 2) * gear_inertia) * (1 - clutch_input)
#	print_debug(drive_inertia)
	
#	var ratio = power_ratio
#	if torque * sign(get_gearing()) < 0:
#		ratio = coast_ratio
	
#	var diff_state = DIFF_STATE.LOCKED
	
#	if diff_type == DIFF_TYPE.OPEN_DIFF:
#		diff_state = DIFF_STATE.OPEN
#	elif diff_type == DIFF_TYPE.LOCKED:
#		diff_state = DIFF_STATE.LOCKED
#	else:
#		if abs(delta_torque) > diff_preload: #* ratio:
#			diff_state = DIFF_STATE.SLIPPING
	
#	print_debug("Diff state = %d" % diff_state)
	
#	match diff_state:
#		DIFF_STATE.OPEN:
#			var diff_sum := 0.0
#			t2 *= _diff_split
#			t1 *= (1 - _diff_split)
			
#			diff_sum += wheels[0].apply_torque(t1, brake_torque * 0.5, drive_inertia, delta)
#			diff_sum -= wheels[1].apply_torque(t2, brake_torque * 0.5, drive_inertia, delta)
#			_diff_split = 0.5 * (clamp(diff_sum, -1.0, 1.0) + 1.0)
		
#		DIFF_STATE.SLIPPING:
#			_diff_clutch.friction = diff_preload
#			var diff_torques = _diff_clutch.get_reaction_torques(wheels[0].get_spin(), wheels[1].get_spin(), 0.0, 0.0)
##			print_debug("diff internal torques = " +  str(diff_torques))
#			t1 += diff_torques.x
#			t2 += diff_torques.y
#
#			var diff_sum := 0.0
#			diff_sum += wheels[0].apply_torque(t1, brake_torque * 0.5, drive_inertia, delta)
#			diff_sum -= wheels[1].apply_torque(t2, brake_torque * 0.5, drive_inertia, delta)
#			_diff_split = 0.5 * (clamp(diff_sum, -1.0, 1.0) + 1.0)
		
		
#		DIFF_STATE.LOCKED:
#			var net_torque = wheels[0].get_reaction_torque() + wheels[1].get_reaction_torque()
#			net_torque += t1 + t2
#			var spin: float
#			var avg_spin = (wheels[0].get_spin() + wheels[1].get_spin()) * 0.5
#			var rolling_resistance = wheels[0].rolling_resistance + wheels[1].rolling_resistance
#			if abs(avg_spin) < 5.0 and brake_torque > abs(t1 + t2):
#				spin = 0.0
#			else:
#				net_torque -= (brake_torque + rolling_resistance) * sign(avg_spin)
#			spin = avg_spin + delta * net_torque / (wheels[0].wheel_inertia + drive_inertia + wheels[1].wheel_inertia)
#			wheels[0].set_spin(spin)
#			wheels[1].set_spin(spin)
				
#			_diff_split = 0.5


#func drivetrain(torque: float, rear_brake_torque: float, front_brake_torque: float, wheels: Array, clutch_input: float, delta: float):
#	var rear_wheels = [wheels[0], wheels[1]]
#	var front_wheels = [wheels[2], wheels[3]]
#
#	var drive_torque = torque * get_gearing()
#
#	if drivetype == DRIVE_TYPE.RWD:
#		differential(drive_torque, rear_brake_torque, rear_wheels, rear_diff_preload,
#					rear_diff_coast_ratio, rear_diff_power_ratio, rear_diff, clutch_input, delta)
#		front_wheels[0].apply_torque(0.0, front_brake_torque * 0.5, 0.0, delta)
#		front_wheels[1].apply_torque(0.0, front_brake_torque * 0.5, 0.0, delta)
#
#	elif drivetype == DRIVE_TYPE.FWD:
#		differential(drive_torque, front_brake_torque, front_wheels, front_diff_preload,
#					front_diff_coast_ratio, front_diff_power_ratio, front_diff, clutch_input, delta)
#		rear_wheels[0].apply_torque(0.0, rear_brake_torque * 0.5, 0.0, delta)
#		rear_wheels[1].apply_torque(0.0, rear_brake_torque * 0.5, 0.0, delta)
#
#
#	elif drivetype == DRIVE_TYPE.AWD:
#		var rear_drive = drive_torque * (1 - center_split_fr)
#		var front_drive = drive_torque * center_split_fr
#
#		differential(rear_drive, rear_brake_torque, rear_wheels, rear_diff_preload,
#					rear_diff_coast_ratio, rear_diff_power_ratio, rear_diff, clutch_input, delta)
#
#		differential(front_drive, front_brake_torque, front_wheels, front_diff_preload,
#					front_diff_coast_ratio, front_diff_power_ratio, front_diff, clutch_input, delta)



func automatic_shifting(cur_torque, lower_gear_torque, higher_gear_torque, rpm, max_rpm, brake_input, speed):
	if !drivetrain_params.automatic:
		return
		
	var reversing = false
	var shift_time = 700
	
	if selected_gear == -1:
		reversing = true

	if higher_gear_torque > cur_torque and selected_gear >= 0:
		if rpm > 0.85 * max_rpm:
			if Time.get_ticks_msec() - last_shift_time > shift_time:
				shift_up()
	
	if selected_gear > 1 and rpm < 0.5 * max_rpm and lower_gear_torque > cur_torque:
		if Time.get_ticks_msec() - last_shift_time > shift_time:
			shift_down()
	
	if abs(selected_gear) <= 1 and abs(speed) < 3.0 and brake_input > 0.2:
		if not reversing:
			if Time.get_ticks_msec() - last_shift_time > shift_time:
				shift_down()
		else:
			if Time.get_ticks_msec() - last_shift_time > shift_time:
				shift_up()


func set_selected_gear(gear):
	gear = clamp(gear, -1, drivetrain_params.gear_ratios.size())
	selected_gear = gear


func shift_up():
	if selected_gear < drivetrain_params.gear_ratios.size():
		selected_gear += 1
		last_shift_time = Time.get_ticks_msec()
		set_selected_gear(selected_gear)


func shift_down():
	if selected_gear > -1:
		selected_gear -= 1
		last_shift_time = Time.get_ticks_msec()
		set_selected_gear(selected_gear)


func get_gearing() -> float:
	if selected_gear > drivetrain_params.gear_ratios.size():
		return 0.0
	if selected_gear > 0:
		return drivetrain_params.gear_ratios[selected_gear - 1] * drivetrain_params.final_drive
	if selected_gear == -1:
		return -drivetrain_params.reverse_ratio * drivetrain_params.final_drive
	return 0.0


func set_input_inertia(value):
	_engine_inertia =  value


func differential(torque: float, brake_torque, wheels, diff: DiffParameters, delta: float):
	var diff_state = DIFF_STATE.LOCKED
	var tr1 = abs(wheels[0].get_reaction_torque())
	var tr2 = abs(wheels[1].get_reaction_torque())
	
	var delta_torque := 0.0
	var bias := 0.0
	
	if tr1 >= tr2:
		bias = tr1 / tr2
		delta_torque = tr1 - tr2
	else:
		bias = tr2 / tr1
		delta_torque = tr2 - tr1
	
	var t1 := torque * 0.5
	var t2 := torque * 0.5
	
	var ratio = diff.power_ratio
	if torque * sign(get_gearing()) < 0:
		ratio = diff.coast_ratio
	
	if diff.diff_type == DIFF_TYPE.OPEN_DIFF:
		diff_state = DIFF_STATE.OPEN
	
	elif diff.diff_type == DIFF_TYPE.LOCKED:
		diff_state = DIFF_STATE.LOCKED
	
	else:
		if abs(delta_torque) > diff.diff_preload and bias >= ratio:
			diff_state = DIFF_STATE.SLIPPING
	
	match diff_state:
		DIFF_STATE.OPEN:
			var diff_sum := 0.0
			t2 *= _diff_split
			t1 *= (1 - _diff_split)
			
			diff_sum += wheels[0].apply_torque(t1, brake_torque * 0.5, drive_inertia, delta)
			diff_sum -= wheels[1].apply_torque(t2, brake_torque * 0.5, drive_inertia, delta)
			_diff_split = 0.5 * (clamp(diff_sum, -1.0, 1.0) + 1.0)
		
		DIFF_STATE.SLIPPING:
			_diff_clutch.friction = diff.diff_preload
			
			var diff_torques = _diff_clutch.get_reaction_torques(wheels[0].get_spin(), wheels[1].get_spin(), 0.0, 0.0)
			t1 += diff_torques.x
			t2 += diff_torques.y
			
			wheels[0].apply_torque(t1, brake_torque * 0.5, drive_inertia, delta)
			wheels[1].apply_torque(t2, brake_torque * 0.5, drive_inertia, delta)
			
		DIFF_STATE.LOCKED:
			var net_torque = wheels[0].get_reaction_torque() + wheels[1].get_reaction_torque()
			net_torque += t1 + t2
			
			var spin := 0.0
			var avg_spin = (wheels[0].get_spin() + wheels[1].get_spin()) * 0.5
			var rolling_resistance = wheels[0].rolling_resistance + wheels[1].rolling_resistance
			
			if abs(avg_spin) < 5.0 and brake_torque > abs(net_torque):
				spin = 0.0
			else:
				net_torque -= (brake_torque + rolling_resistance) * sign(avg_spin)
			
			spin = avg_spin + delta * net_torque / (wheels[0].wheel_inertia + drive_inertia + wheels[1].wheel_inertia)
			wheels[0].set_spin(spin)
			wheels[1].set_spin(spin)


func drivetrain(torque: float, rear_brake_torque: float, front_brake_torque: float, wheels: Array, clutch_input: float, delta: float):
	var rear_wheels = [wheels[0], wheels[1]]
	var front_wheels = [wheels[2], wheels[3]]
	
	avg_rear_spin = (wheels[0].get_spin() + wheels[1].get_spin()) * 0.5
	avg_front_spin = (wheels[2].get_spin() + wheels[3].get_spin()) * 0.5 
	
	drive_inertia = (_engine_inertia + pow(abs(get_gearing()), 2) * drivetrain_params.gear_inertia) * (1 - clutch_input)
	var drive_torque = torque * get_gearing() * drivetrain_params.drivetrain_efficiency
	
	if drivetrain_params.drivetype == DRIVE_TYPE.RWD:
		differential(drive_torque, rear_brake_torque, rear_wheels, drivetrain_params.rear_diff, delta)
		front_wheels[0].apply_torque(0.0, front_brake_torque * 0.5, 0.0, delta)
		front_wheels[1].apply_torque(0.0, front_brake_torque * 0.5, 0.0, delta)
	
	elif drivetrain_params.drivetype == DRIVE_TYPE.FWD:
		differential(drive_torque, front_brake_torque, front_wheels, drivetrain_params.front_diff, delta)
		rear_wheels[0].apply_torque(0.0, rear_brake_torque * 0.5, 0.0, delta)
		rear_wheels[1].apply_torque(0.0, rear_brake_torque * 0.5, 0.0, delta)
	
	elif drivetrain_params.drivetype == DRIVE_TYPE.AWD:
		match drivetrain_params.center_diff.diff_type:
			DIFF_TYPE.LOCKED: # Locked center diff currently means raw 4x4 
				var avg_spin = (avg_front_spin + avg_rear_spin) * 0.5
				
				var net_torque := 0.0
				var combined_wheel_inertias := 0.0
				var rolling_resistance := 0.0
				
				for w in wheels:
					net_torque += w.get_reaction_torque()
					combined_wheel_inertias += w.wheel_inertia
					rolling_resistance += w.rolling_resistance
					
				net_torque += drive_torque
				var brake_torque := rear_brake_torque + front_brake_torque
				var spin := 0.0
				
				if abs(avg_spin) < 5.0 and brake_torque > abs(net_torque):
					spin = 0.0
				else:
					net_torque -= (brake_torque + abs(rolling_resistance)) * sign(avg_spin)
					spin = avg_spin + delta * net_torque / (drive_inertia + combined_wheel_inertias)
				
				wheels[0].set_spin(spin)
				wheels[1].set_spin(spin)
				wheels[2].set_spin(spin)
				wheels[3].set_spin(spin)
			
			DIFF_TYPE.LIMITED_SLIP:
				var rear_drive = drive_torque * (1 - drivetrain_params.center_split_fr)
				var front_drive = drive_torque * drivetrain_params.center_split_fr
				
				differential(rear_drive, rear_brake_torque, rear_wheels, drivetrain_params.rear_diff, delta)
				differential(front_drive, front_brake_torque, front_wheels, drivetrain_params.front_diff, delta)
			
			DIFF_TYPE.OPEN_DIFF:
				var rear_drive = drive_torque * 0.5
				var front_drive = drive_torque * 0.5
				
				differential(rear_drive, rear_brake_torque, rear_wheels, drivetrain_params.rear_diff, delta)
				differential(front_drive, front_brake_torque, front_wheels, drivetrain_params.front_diff, delta)
