class_name PlayerDriver
extends BaseDriver

var steering_value := 0.0
var steer_speed := 5.0

@onready var car = get_parent()


func _ready():
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift_up") or event.is_action_pressed("shift_up_secondary"):
		car.shift_up()
	if event.is_action_pressed("shift_down") or event.is_action_pressed("shift_down_secondary"):
		car.shift_down()


func _process(delta: float) -> void:
	brake_input = InputManager.get_brake_input()
	steering_input = InputManager.get_steering_input()
	throttle_input = InputManager.get_throttle_input()
	handbrake_input = InputManager.get_handbrake_input()
	clutch_input = InputManager.get_clutch_input()
	
	VehicleAPI.tires[0].tire_wear = car.wheel_bl.tire_wear
	VehicleAPI.tires[1].tire_wear = car.wheel_br.tire_wear
	VehicleAPI.tires[2].tire_wear = car.wheel_fl.tire_wear
	VehicleAPI.tires[3].tire_wear = car.wheel_fr.tire_wear
	
		##### Steerin with steer speed #####
	if OptionsManager.get_config_value("steering_interpolation"):
		steering_value = steer_lerp(steering_input, steering_value, steer_speed, delta)
	
	car.throttle_input = throttle_input
	car.steering_input = steering_value
	car.brake_input = brake_input
	car.handbrake_input = handbrake_input
	car.clutch_input = clutch_input


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



