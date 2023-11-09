extends Control


func _on_resume_pressed() -> void:
	self.hide()


func _on_reset_car_pressed() -> void:
	pass # Replace with function body.


func _on_goto_pits_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gui/menus/main_menu.tscn")
