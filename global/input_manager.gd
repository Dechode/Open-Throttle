extends Node


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass


func get_steering_input():
	var steer_left = max(Input.get_action_strength("steer_left"), 
		Input.get_action_strength("steer_left_secondary"))
	var steer_right = max(Input.get_action_strength("steer_right"), 
		Input.get_action_strength("steer_right_secondary"))
	var steering_input = steer_left - steer_right
	return steering_input


func get_throttle_input():
	var exact = OptionsManager.get_config_value("throttle_minus_one_to_one")
	var exact_sec = OptionsManager.get_config_value("throttle_minus_one_to_one_sec")
	var throttle_input = Input.get_action_strength("throttle", exact)
	var throttle_input_sec = Input.get_action_strength("throttle_secondary", exact_sec)
	
	if exact:
		throttle_input = (1 + throttle_input) * 0.5
	if exact_sec:
		throttle_input_sec = (1 + throttle_input_sec) * 0.5
	
	if OptionsManager.get_config_value("throttle_inverted"):
		print("Throttle inverted")
		throttle_input = 1 - throttle_input
	
	if OptionsManager.get_config_value("throttle_inverted_sec"):
		throttle_input_sec = 1 - throttle_input_sec
	
	throttle_input = max(throttle_input, throttle_input_sec)
	return throttle_input


func get_brake_input():
	var exact = OptionsManager.get_config_value("brake_minus_one_to_one")
	var exact_sec = OptionsManager.get_config_value("brake_minus_one_to_one_sec")
	var brake_input = Input.get_action_strength("brake", exact)
	var brake_input_sec = Input.get_action_strength("brake_secondary", exact_sec)
	
	if exact:
		brake_input = (1 + brake_input) * 0.5
	if exact_sec:
		brake_input_sec = (1 + brake_input_sec) * 0.5
	
	if OptionsManager.get_config_value("brake_inverted"):
		brake_input = 1 - brake_input
	if OptionsManager.get_config_value("brake_inverted_sec"):
		brake_input_sec = 1 - brake_input_sec
	
	brake_input = max(brake_input, brake_input_sec)
	return brake_input


func get_clutch_input():
	var exact = OptionsManager.get_config_value("clutch_minus_one_to_one")
	var exact_sec = OptionsManager.get_config_value("clutch_minus_one_to_one_sec")
	var clutch_input = Input.get_action_strength("clutch",exact)
	var clutch_input_sec = Input.get_action_strength("clutch_secondary", exact_sec)
	
	if exact:
		clutch_input = (1 + clutch_input) * 0.5
	if exact_sec:
		clutch_input_sec = (1 + clutch_input_sec) * 0.5
	
	if OptionsManager.get_config_value("clutch_inverted"):
		clutch_input = 1 - clutch_input
	if OptionsManager.get_config_value("clutch_inverted_sec"):
		clutch_input_sec = 1 - clutch_input_sec
	
	clutch_input = max(clutch_input, clutch_input_sec)
	return clutch_input


func get_handbrake_input():
	var exact = OptionsManager.get_config_value("handbrake_minus_one_to_one")
	var exact_sec = OptionsManager.get_config_value("handbrake_minus_one_to_one_sec")
	var handbrake_input = Input.get_action_strength("handbrake",exact)
	var handbrake_input_sec = Input.get_action_strength("handbrake_secondary", exact_sec)
	
	if exact:
		handbrake_input = (1 + handbrake_input) * 0.5
	if exact_sec:
		handbrake_input_sec = (1 + handbrake_input_sec) * 0.5
	
	if OptionsManager.get_config_value("handbrake_inverted"):
		handbrake_input = 1 - handbrake_input
	if OptionsManager.get_config_value("handbrake_inverted_sec"):
		handbrake_input_sec = 1 - handbrake_input_sec
	
	handbrake_input = max(handbrake_input, handbrake_input_sec)
	return handbrake_input
	
