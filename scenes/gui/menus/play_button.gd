extends Button


func _ready():
	pass


func _on_tab_changed(tab:int):
	if tab != 2:
		return

	if SessionManager.track_path == "":
		return
	
	if SessionManager.player_car_path == "":
		return
	self.disabled = false



func _on_PlayButton_pressed():
	if SessionManager.track_path == "":
		return
	
	if get_tree().change_scene_to_file(SessionManager.track_path) != OK:
		push_error("Could not change scene to %s" % SessionManager.track_path)
	
