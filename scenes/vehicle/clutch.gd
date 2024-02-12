class_name Clutch
extends Node

@export var friction := 250.0

var locked := true


func get_reaction_torques(av1: float, av2: float, t1: float, t2: float, slip_torque: float, kick := 0.0) -> Vector2:
	var clutch_torque := friction + kick
	var delta_torque := t1 - t2
	var delta_av := av1 - av2
	var reaction_torques := Vector2.ZERO
	
	if locked:
		if absf(delta_torque) >= slip_torque:
			locked = false
	else:
		if absf(delta_av) < 0.5:
			locked = true
	
	if av1 < av2:
		reaction_torques.x = -clutch_torque
		reaction_torques.y = clutch_torque
	else:
		reaction_torques.x = clutch_torque
		reaction_torques.y = -clutch_torque
	return reaction_torques
	
