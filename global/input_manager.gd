extends Node

var throttle_axis := -1
var brake_axis := -1
var clutch_axis := -1
var handbrake_axis := -1

var throttle_axis_sec := -1
var brake_axis_sec := -1
var clutch_axis_sec := -1
var handbrake_axis_sec := -1

var throttle_device := -1
var brake_device := -1
var clutch_device := -1
var handbrake_device := -1
var steering_device := -1

var throttle_device_sec := -1
var brake_device_sec := -1
var clutch_device_sec := -1
var handbrake_device_sec := -1
var steering_device_sec := -1

var throttle_used := false
var brake_used := false
var clutch_used := false
var handbrake_used := false

var throttle_sec_used := false
var brake_sec_used := false
var clutch_sec_used := false
var handbrake_sec_used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_input_devices()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("brake"):
		brake_used = true
	
	if  event.is_action("brake_secondary"):
		brake_sec_used = true
	
	if event.is_action("handbrake"):
		handbrake_used = true
		
	if  event.is_action("handbrake_secondary"):
		handbrake_sec_used = true
	
	if event.is_action("throttle"):
		throttle_used = true
	
	if event.is_action("throttle_secondary"):
		throttle_sec_used = true
		
	if event.is_action("clutch"):
		clutch_used = true
	
	if event.is_action("clutch_secondary"):
		clutch_sec_used = true

# Updates DeviceID and possible Axises for all of the input actions 
func update_input_devices():
	var actions := InputMap.get_actions()
	for action in actions:
		var events := InputMap.action_get_events(action)
		
		if action == "steer_left":
			for event in events:
				if event is InputEventJoypadMotion:
					steering_device = event.device
		
		if action == "steer_right":
			for event in events:
				if event is InputEventJoypadMotion:
					if event.device != steering_device:
						push_warning("Steer right and steer left were not on same device")
					steering_device = event.device
		
		if action == "throttle":
			for event in events:
				if event is InputEventJoypadMotion:
					throttle_axis = event.axis
					throttle_device = event.device
		
		if action == "brake":
			for event in events:
				if event is InputEventJoypadMotion:
					brake_axis = event.axis
					brake_device = event.device
		
		if action == "clutch":
			for event in events:
				if event is InputEventJoypadMotion:
					clutch_axis = event.axis
					clutch_device = event.device
		
		if action == "handbrake":
			for event in events:
				if event is InputEventJoypadMotion:
					handbrake_axis = event.axis
					handbrake_device = event.device
		
		if action == "throttle_sec":
			for event in events:
				if event is InputEventJoypadMotion:
					throttle_axis_sec = event.axis
					throttle_device_sec = event.device
		
		if action == "brake_sec":
			for event in events:
				if event is InputEventJoypadMotion:
					brake_axis_sec = event.axis
					brake_device_sec = event.device
		
		if action == "clutch_sec":
			for event in events:
				if event is InputEventJoypadMotion:
					clutch_axis_sec = event.axis
					clutch_axis_sec = event.device
		
		if action == "handbrake_sec":
			for event in events:
				if event is InputEventJoypadMotion:
					handbrake_axis_sec = event.axis
					handbrake_device_sec = event.device
		
		if action == "steer_left_sec":
			for event in events:
				if event is InputEventJoypadMotion:
					steering_device_sec = event.device
		
		if action == "steer_right_sec":
			for event in events:
				if event is InputEventJoypadMotion:
					if event.device != steering_device_sec:
						push_warning("Steer right and steer left were not on same device")
					steering_device_sec = event.device


func get_steering_input() -> float:
	var steer_left := maxf(Input.get_action_strength("steer_left"), 
						Input.get_action_strength("steer_left_secondary"))
	var steer_right := maxf(Input.get_action_strength("steer_right"), 
						Input.get_action_strength("steer_right_secondary"))
	var steering_input := steer_left - steer_right
	return steering_input


func get_throttle_input():
	var minus1to1 = OptionsManager.get_config_value("throttle_minus_one_to_one")
	var minus1to1_sec = OptionsManager.get_config_value("throttle_minus_one_to_one_sec")
	var throttle_input = Input.get_action_strength("throttle")
	var throttle_input_sec = Input.get_action_strength("throttle_secondary")
	
	if throttle_axis >= 0:
		throttle_input = Input.get_joy_axis(throttle_device, throttle_axis)
		if minus1to1:
			throttle_input = (1 + throttle_input) * 0.5
	
	if throttle_axis_sec >= 0:
		throttle_input_sec = Input.get_joy_axis(throttle_device_sec, throttle_axis_sec)
		if minus1to1_sec:
			throttle_input_sec = (1 + throttle_input_sec) * 0.5
		
	if OptionsManager.get_config_value("throttle_inverted"):
		throttle_input = 1 - throttle_input
	
	if OptionsManager.get_config_value("throttle_inverted_sec"):
		throttle_input_sec = 1 - throttle_input_sec
	
	if not throttle_used:
		throttle_input = 0.0
	
	if not throttle_sec_used:
		throttle_input_sec = 0.0
		
	throttle_input = max(throttle_input, throttle_input_sec)
	throttle_input = clamp(throttle_input, 0, 1)
	return throttle_input


func get_brake_input():
	var minus1to1 = OptionsManager.get_config_value("brake_minus_one_to_one")
	var minus1to1_sec = OptionsManager.get_config_value("brake_minus_one_to_one_sec")
	var brake_input = Input.get_action_strength("brake")
	var brake_input_sec = Input.get_action_strength("brake_secondary")
		
	if brake_axis >= 0:
		brake_input = Input.get_joy_axis(brake_device, brake_axis)
		if minus1to1:
			brake_input = (1 + brake_input) * 0.5
	
	if brake_axis_sec >= 0:
		brake_input_sec = Input.get_joy_axis(brake_device_sec, brake_axis_sec)
		if minus1to1_sec:
			brake_input_sec = (1 + brake_input_sec) * 0.5
	
	if OptionsManager.get_config_value("brake_inverted"):
		brake_input = 1 - brake_input
	
	if OptionsManager.get_config_value("brake_inverted_sec"):
		brake_input_sec = 1 - brake_input_sec
	
	if not brake_used:
		brake_input = 0.0
		
	if not brake_sec_used:
		brake_input_sec = 0.0
	
	brake_input = max(brake_input, brake_input_sec)
	brake_input = clamp(brake_input, 0, 1)
	
	return brake_input


func get_clutch_input():
	var minus1to1 = OptionsManager.get_config_value("clutch_minus_one_to_one")
	var minus1to1_sec = OptionsManager.get_config_value("clutch_minus_one_to_one_sec")
	var clutch_input = Input.get_action_strength("clutch")
	var clutch_input_sec = Input.get_action_strength("clutch_secondary")
	
	if clutch_axis >= 0:
		clutch_input = Input.get_joy_axis(clutch_device, clutch_axis)
		if minus1to1:
			clutch_input = (1 + clutch_input) * 0.5
	
	if clutch_axis_sec >= 0:
		clutch_input_sec = Input.get_joy_axis(clutch_device_sec, clutch_axis_sec)
		if minus1to1_sec:
			clutch_input_sec = (1 + clutch_input_sec) * 0.5
	
	if OptionsManager.get_config_value("clutch_inverted"):
		clutch_input = 1 - clutch_input
	
	if OptionsManager.get_config_value("clutch_inverted_sec"):
		clutch_input_sec = 1 - clutch_input_sec
	
	if not clutch_used:
		clutch_input = 0.0
		
	if not clutch_sec_used:
		clutch_input_sec = 0.0
	
	clutch_input = max(clutch_input, clutch_input_sec)
	clutch_input = clamp(clutch_input, 0, 1)
	return clutch_input


func get_handbrake_input():
	if not handbrake_used:
		return 0.0
	
	var minus1to1 = OptionsManager.get_config_value("handbrake_minus_one_to_one")
	var minus1to1_sec = OptionsManager.get_config_value("handbrake_minus_one_to_one_sec")
	var handbrake_input = Input.get_action_strength("handbrake")
	var handbrake_input_sec = Input.get_action_strength("handbrake_secondary")
	if handbrake_axis >= 0:
		handbrake_input = Input.get_joy_axis(handbrake_device, handbrake_axis)
		if minus1to1:
			handbrake_input = (1 + handbrake_input) * 0.5
	
	if handbrake_axis_sec >= 0:
		handbrake_input_sec = Input.get_joy_axis(handbrake_device_sec, handbrake_axis_sec)
		if minus1to1_sec:
			handbrake_input_sec = (1 + handbrake_input_sec) * 0.5
	
	if OptionsManager.get_config_value("handbrake_inverted"):
		handbrake_input = 1 - handbrake_input
	
	if OptionsManager.get_config_value("handbrake_inverted_sec"):
		handbrake_input_sec = 1 - handbrake_input_sec
	
	if not handbrake_used:
		handbrake_input = 0.0
	
	if not handbrake_sec_used:
		handbrake_input_sec = 0.0
	
	handbrake_input = max(handbrake_input, handbrake_input_sec)
	handbrake_input = clamp(handbrake_input, 0, 1)
	return handbrake_input
	
