class_name CarPreview
extends Node3D


func _ready():
	pass


func _on_car_selected():
	for child in $CarSpawner/Marker3D.get_children():
		child.queue_free()
		print_debug("Child queued free")
	var car = load(SessionManager.player_car_path).instantiate()
	$CarSpawner.add_car(car, 0)

