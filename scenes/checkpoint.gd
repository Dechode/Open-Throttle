class_name CheckPoint
extends Node3D

@export var is_finish_line := false


func _on_checkpoint_body_entered(body: Node3D) -> void:
	if !body is BaseCar:
		return
	
	if is_finish_line:
		body.lap_timer.cross_finish_line()
		
