class_name CheckPoint
extends Node3D

@export var is_start_or_finish := false


func _on_checkpoint_body_entered(body: Node3D) -> void:
	if not body is BaseCar:
		return
	
	if is_start_or_finish:
		body.lap_timer.cross_finish_line()
	else:
		body.lap_timer.cross_checkpoint(self)
