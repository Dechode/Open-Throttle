extends Control


func _ready() -> void:
	self.hide()
	$HideOptionsButtons.hide()


#func _unhandled_input(event: InputEvent) -> void:
	# TODO toggle pause menu when hitting pause key/button.
	# For some reason calling resume() here gives weird error about p_elem->_root,
	# but that does not happen when pressing the resume button
	
#	if event.is_action_pressed("pause"):
#		resume()
#		call_deferred("resume")


func pause():
	get_tree().paused = true
	self.show()


func resume():
	print_debug("Resume called")
	self.hide()
	get_tree().paused = false


func _on_resume_pressed() -> void:
	resume()


func _on_reset_car_pressed() -> void:
	VehicleAPI.car.reset_car()
	resume()


func _on_goto_pits_pressed() -> void:
	# TODO implement pits
	pass # Replace with function body.


func _on_options_pressed() -> void:
	$Options.show()
	$OptionsPanel.show()
	$HideOptionsButtons.show()
	$MenuPanel.hide()


func _on_quit_to_menu_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/gui/menus/main_menu.tscn")


func _on_hide_options_pressed() -> void:
	$OptionsPanel.hide()
	$Options.hide()
	$HideOptionsButtons.hide()
	$MenuPanel.show()
