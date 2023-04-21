extends TabContainer

var aspect_ratios := [Vector2(4,3), Vector2(16,9), Vector2(19,10)]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GamePlay/VBoxContainer/SteeringInterpolation/CheckButton.button_pressed = OptionsManager.get_config_value("steering_interpolation")
	$Graphics/VBoxContainer/Fullscreen/CheckButton.button_pressed = OptionsManager.get_config_value("fullscreen")
	$Graphics/VBoxContainer/VSync/CheckButton.button_pressed = OptionsManager.get_config_value("vsync")
	$Audio/VBoxContainer/MasterVolume/HSlider.value = OptionsManager.get_config_value("master_audio_vol") * 100
	
	$Graphics/VBoxContainer/AspectRatio/OptionButton.clear()
	for ratio in aspect_ratios:
		$Graphics/VBoxContainer/AspectRatio/OptionButton.add_item(str(ratio))
	var aspect_ratio_idx = OptionsManager.get_config_value("aspect_ratio")
	$Graphics/VBoxContainer/AspectRatio/OptionButton.selected = aspect_ratio_idx
	_set_res_items(aspect_ratio_idx)
	$Graphics/VBoxContainer/Resolution/OptionButton.selected = OptionsManager.get_config_value("resolution")
	$Graphics/VBoxContainer/Shadows/CheckButton.button_pressed = OptionsManager.get_config_value("shadows")
	
	$Input/VBoxContainer/SteerLeft/CheckBox.button_pressed = OptionsManager.get_config_value("steer_left_inverted")
	$Input/VBoxContainer/SteerLeft/CheckBox2.button_pressed = OptionsManager.get_config_value("steer_left_inverted_sec")
	$Input/VBoxContainer/SteerRight/CheckBox.button_pressed = OptionsManager.get_config_value("steer_right_inverted")
	$Input/VBoxContainer/SteerRight/CheckBox2.button_pressed = OptionsManager.get_config_value("steer_right_inverted_sec")

	$Input/VBoxContainer/Throttle/CheckBox.button_pressed = OptionsManager.get_config_value("throttle_inverted")
	$Input/VBoxContainer/Throttle/CheckBox2.button_pressed = OptionsManager.get_config_value("throttle_inverted_sec")
	$Input/VBoxContainer/Brake/CheckBox.button_pressed = OptionsManager.get_config_value("brake_inverted")
	$Input/VBoxContainer/Brake/CheckBox2.button_pressed = OptionsManager.get_config_value("brake_inverted_sec")

	$Input/VBoxContainer/Clutch/CheckBox.button_pressed = OptionsManager.get_config_value("clutch_inverted")
	$Input/VBoxContainer/Clutch/CheckBox2.button_pressed = OptionsManager.get_config_value("clutch_inverted_sec")
	$Input/VBoxContainer/Handbrake/CheckBox.button_pressed = OptionsManager.get_config_value("handbrake_inverted")
	$Input/VBoxContainer/Handbrake/CheckBox2.button_pressed = OptionsManager.get_config_value("handbrake_inverted_sec")

	$Input/VBoxContainer/Throttle/OptionButton.selected = OptionsManager.get_config_value("throttle_minus_one_to_one")
	$Input/VBoxContainer/Throttle/OptionButton2.selected = OptionsManager.get_config_value("throttle_minus_one_to_one_sec")
	$Input/VBoxContainer/Brake/OptionButton.selected = OptionsManager.get_config_value("brake_minus_one_to_one")
	$Input/VBoxContainer/Brake/OptionButton2.selected = OptionsManager.get_config_value("brake_minus_one_to_one_sec")

	$Input/VBoxContainer/Clutch/OptionButton.selected = OptionsManager.get_config_value("clutch_minus_one_to_one")
	$Input/VBoxContainer/Clutch/OptionButton2.selected = OptionsManager.get_config_value("clutch_minus_one_to_one_sec")
	$Input/VBoxContainer/Handbrake/OptionButton.selected = OptionsManager.get_config_value("handbrake_minus_one_to_one")
	$Input/VBoxContainer/Handbrake/OptionButton2.selected = OptionsManager.get_config_value("handbrake_minus_one_to_one_sec")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_steering_interpolation_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("steering_interpolation" ,button_pressed)


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	OptionsManager.set_fullscreen(button_pressed)


func _on_vsync_toggled(button_pressed: bool) -> void:
	OptionsManager.set_vsync(button_pressed)


func _on_master_audio_changed(value: float) -> void:
	OptionsManager.set_config_value("master_audio_vol", value * 0.01)
	$Audio/VBoxContainer/MasterVolume/Label2.text = str(value)


func _on_aspect_ratio_selected(index: int) -> void:
	OptionsManager.set_config_value("aspect_ratio", index)
	_set_res_items(index)


func _set_res_items(aspect):
	$Graphics/VBoxContainer/Resolution/OptionButton.clear()
	for res in OptionsManager.resolutions[aspect]:
		$Graphics/VBoxContainer/Resolution/OptionButton.add_item(str(res))


func _on_resolution_selected(index: int) -> void:
	OptionsManager.set_resolution(index)


func _on_shadows_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("shadows", button_pressed)


func _on_throttle_range_selected(index: int) -> void:
	OptionsManager.set_config_value("throttle_minus_one_to_one", index)


func _on_throttle_sec_range_selected(index: int) -> void:
	OptionsManager.set_config_value("throttle_minus_one_to_one_sec", index)


func _on_brake_range_selected(index: int) -> void:
	OptionsManager.set_config_value("brake_minus_one_to_one", index)


func _on_brake_sec_range_selected(index: int) -> void:
	OptionsManager.set_config_value("brake_minus_one_to_one_sec", index)


func _on_clutch_range_selected(index: int) -> void:
	OptionsManager.set_config_value("clutch_minus_one_to_one", index)


func _on_clutch_sec_range_selected(index: int) -> void:
		OptionsManager.set_config_value("clutch_minus_one_to_one_sec", index)


func _on_handbrake_range_selected(index: int) -> void:
	OptionsManager.set_config_value("handbrake_minus_one_to_one", index)


func _on_handbrake_sec_range_selected(index: int) -> void:
	OptionsManager.set_config_value("handbrake_minus_one_to_one_sec", index)


func _on_throttle_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("throttle_inverted", button_pressed)


func _on_throttle_sec_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("throttle_inverted_sec", button_pressed)


func _on_brake_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("brake_inverted", button_pressed)


func _on_brake_sec_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("brake_inverted", button_pressed)


func _on_clutch_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("clutch_inverted", button_pressed)


func _on_clutch_sec_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("clutch_inverted_sec", button_pressed)


func _on_handbrake_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("handbrake_inverted", button_pressed)


func _on_handbrake_sec_inverted_toggled(button_pressed: bool) -> void:
	OptionsManager.set_config_value("handbrake_inverted_sec", button_pressed)

