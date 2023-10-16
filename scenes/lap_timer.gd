class_name LapTimer
extends Node

signal lap_finished

var last_lap_time_usec := 0
var lap_start_time_usec := 0
var lap := 0

var checkpoints_done := []
var checkpoints_count := 0


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
	if checkpoint.is_start_or_finish:
		cross_finish_line()
		return
	
	if not checkpoint in checkpoints_done:
		checkpoints_done.append(checkpoint)


func get_lap_time_str(usec: int) -> String:
	var msec: int = int(fmod(usec / 1000.0, 1000))
	var sec: int = int(fmod(usec / 1000000.0, 60))
	var minutes: int = int(fmod(usec / 1000000.0, 60 * 60) / 60)
	return "%02d:%02d:%03d" % [minutes, sec, msec]
