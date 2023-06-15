class_name LapTimer
extends Node

signal lap_finished

var last_lap_time_usec := 0
var lap_start_time_usec := 0
var lap := 0

var checkpoints_done := 0


func cross_finish_line():
	last_lap_time_usec = Time.get_ticks_usec() - lap_start_time_usec
	lap_start_time_usec = Time.get_ticks_usec()
	lap += 1
	checkpoints_done = 0
	
	lap_finished.emit()


func cross_checkpoint():
	checkpoints_done += 1


func get_lap_time_str(usec: int) -> String:
	var msec: int = fmod(float(usec / 1000), 1000)
	var sec: int = fmod(usec / 1000000, 60)
	var min: int = fmod(usec / 1000000, 60 * 60) / 60
	return "%02d:%02d:%03d" % [min, sec, msec]
