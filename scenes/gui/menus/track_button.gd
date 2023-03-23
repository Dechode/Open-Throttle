extends Button
@export var path = "" # (String, FILE)

func _ready():
	pass


func _on_TrackButton_pressed():
	SessionManager.set_track_path(path)

