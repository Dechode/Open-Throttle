class_name LapTimer
extends Node

signal lap_finished

var last_lap_time_usec := 0
var lap_start_time_usec := 0
var lap := 0

var checkpoints_done := []
var checkpoints_count := 0

var checkpoints := []

func _ready() -> void:
	
#	TODO Get checkpoint count from RaceControl by making a Track class and make it responsible for 
#	getting the checkpoint count and setting it in RaceControl
	
	for child in get_tree().root.get_children(true):
		if child is CheckPoint:
			print_debug("Checkpoint found")
			if not child.is_start_or_finish:
				checkpoints.append(child)
				continue
		
		for gc in child.get_children(true):
			if gc is CheckPoint:
				print_debug("Checkpoint found")
				if not gc.is_start_or_finish:
					checkpoints.append(gc)
					continue
	
	print_debug(checkpoints)
	checkpoints_count = checkpoints.size()


func cross_finish_line():
	if checkpoints_done.size() < checkpoints_count and lap > 0:
		print_debug("Missed checkpoint(s)")
		return
	
	last_lap_time_usec = Time.get_ticks_usec() - lap_start_time_usec
	lap_start_time_usec = Time.get_ticks_usec()
	lap += 1
	checkpoints_done.clear()
	lap_finished.emit()


func cross_checkpoint(checkpoint):
	if not checkpoint in checkpoints_done:
		checkpoints_done.append(checkpoint)


func get_lap_time_str(usec: int) -> String:
	var msec: int = fmod(usec / 1000, 1000)
	var sec: int = fmod(usec / 1000000, 60)
	var min: int = fmod(usec / 1000000, 60 * 60) / 60
	return "%02d:%02d:%03d" % [min, sec, msec]
