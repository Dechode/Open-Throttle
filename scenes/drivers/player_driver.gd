class_name PlayerDriver
extends Driver



func _ready():
	VehicleAPI.car = car
#	print_debug("created player driver")
#	set_physics_process(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift_up") or event.is_action_pressed("shift_up_secondary"):
		car.shift_up()
	if event.is_action_pressed("shift_down") or event.is_action_pressed("shift_down_secondary"):
		car.shift_down()


func _physics_process(delta: float) -> void:
	brake_input = InputManager.get_brake_input()
	var raw_steering_input = InputManager.get_steering_input()
	throttle_input = InputManager.get_throttle_input()
	handbrake_input = InputManager.get_handbrake_input()
	clutch_input = InputManager.get_clutch_input()
	
	VehicleAPI.car.wheel_bl.tire_wear = car.wheel_bl.tire_wear
	VehicleAPI.car.wheel_br.tire_wear = car.wheel_br.tire_wear
	VehicleAPI.car.wheel_fl.tire_wear = car.wheel_fl.tire_wear
	VehicleAPI.car.wheel_fr.tire_wear = car.wheel_fr.tire_wear
	
		##### Steerin with steer speed #####
	if OptionsManager.get_config_value("steering_interpolation"):
		steering_input = steer_lerp(raw_steering_input, steering_input, steer_speed, delta)
	else:
		steering_input = raw_steering_input


func steer_lerp(input: float, prev_input: float, lerp_speed: float, delta: float):
	var output = prev_input
	if (input < output):
		output -= lerp_speed * delta
		if (input > output):
			output = input

	elif (input > output):
		output += lerp_speed * delta
		if (input < output):
			output = input
	return output



