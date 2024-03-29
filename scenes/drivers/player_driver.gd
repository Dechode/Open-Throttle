class_name PlayerDriver
extends Driver

const GAMEPAD_STEERING_CURVE = preload("res://resources/gamepad_steering_curve.tres")
const PAUSE_MENU_SCENE = preload("res://scenes/gui/menus/pause_menu.tscn")

var ffb := FFBPlugin.new()
var has_ffb := false
var ffb_effect_id := -1

var steering_device := -1
var pause_menu: Node = null


func _ready():
	VehicleAPI.car = car
	# Has to be call_deferred so the car reference is updated in VehicleAPI when instantiating the gui 
	car.add_child.call_deferred((load("res://scenes/gui/gui.tscn").instantiate()))
	
	steer_speed = OptionsManager.get_config_value("steer_speed")
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	
	get_tree().root.add_child(pause_menu)
	
	var devices := []
	if InputManager.steering_device >= 0:
		devices.append(InputManager.steering_device)
#		steering_device = InputManager.steering_device
	if InputManager.steering_device_sec >= 0:
		devices.append(InputManager.steering_device_sec)
	
	var ffb_devices := []
	for dev in devices:
		if ffb.init_ffb(dev) >= 0:
			ffb_devices.append(dev)
	
	if ffb_devices.size() >= 2:
		push_warning("Cant have more than 1 force feedback device connected atm")
	if ffb_devices.size() == 0:
		print_debug("No FFB supported devices found")
		has_ffb = false
	else:
		steering_device = ffb_devices[0]
		has_ffb = true
	
	if has_ffb:
		if OptionsManager.get_config_value("ffb_enabled"):
			ffb_effect_id = ffb.init_constant_force_effect()
			print_debug("Constant Force FFB effect initialised, effect id = %d" % ffb_effect_id)
			
			if ffb.play_constant_force_effect(ffb_effect_id, 0) < 0:
				push_warning("Playing FFB effect failed!")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift_up") or event.is_action_pressed("shift_up_secondary"):
		car.shift_up()
	if event.is_action_pressed("shift_down") or event.is_action_pressed("shift_down_secondary"):
		car.shift_down()
	if event.is_action_pressed("toggle_lights") or event.is_action_pressed("toggle_lights_secondary"):
		car.headlights.toggle_lights()
		car.taillights.toggle_lights()
	if event.is_action_pressed("reset_car") or event.is_action_pressed("reset_car_secondary"):
		car.reset_car()
	if event.is_action_pressed("pause"):
		pause_menu.pause()


func _process(delta: float) -> void:
	if car.headlights and car.taillights:
		if brake_input > 0.15:
			car.taillights.set_brake_lights(true)
		else:
			car.taillights.set_brake_lights(false)


func _physics_process(delta: float) -> void:
	brake_input = InputManager.get_brake_input()
	var raw_steering_input := InputManager.get_steering_input()
	throttle_input = InputManager.get_throttle_input()
	handbrake_input = InputManager.get_handbrake_input()
	clutch_input = InputManager.get_clutch_input()
	
	var pad_steering: float = GAMEPAD_STEERING_CURVE.sample_baked(abs(raw_steering_input)) * sign(raw_steering_input)
	
	var steering := lerpf(raw_steering_input, pad_steering, OptionsManager.get_config_value("gamepad_steering"))
	
		##### Steerin with steer speed #####
	if OptionsManager.get_config_value("steering_interpolation"):
		steering_input = steer_lerp(steering, steering_input, steer_speed, delta)
	else:
		steering_input = steering
	
#	if abs(car.local_vel.z) > 2.0:
	if OptionsManager.get_config_value("ffb_enabled"):
		update_ffb()
	


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


func update_ffb():
	var force_vec: Vector2 = car.get_self_aligning_torques() / (car.mass * 0.25) * 15.0
	var steering_force := 0.0
	
	steering_force += OptionsManager.get_config_value("ffb_front_force") * force_vec.x
	steering_force += OptionsManager.get_config_value("ffb_rear_force") * force_vec.y
	steering_force = max(abs(steering_force), OptionsManager.get_config_value("ffb_min_force")) * sign(steering_force)
	steering_force *= OptionsManager.get_config_value("ffb_gain")
	
	if OptionsManager.get_config_value("ffb_inverted"):
		steering_force *= -1
		
#	print(steering_force)
#	if abs(car.local_vel.z) > 5.0:
	if abs(car.local_vel.length()) > 5.0:
		ffb.update_constant_force_effect(steering_force, 0, ffb_effect_id)
	else:
		ffb.update_constant_force_effect(0.0, 0, ffb_effect_id)
		

