class_name LapTimer
extends Node

var last_lap_time_usec := 0
var lap_start_time_usec := 0
var lap := 0


func cross_finish_line():
	var lap_time_usec := Time.get_ticks_usec() - lap_start_time_usec
	last_lap_time_usec = lap_time_usec
	
	lap_start_time_usec = Time.get_ticks_usec()
	lap += 1


func get_last_lap_time():
	var msec: int = fmod(last_lap_time_usec / 1000000, 1000)
	var sec: int = fmod(last_lap_time_usec / 1000000, 60)
	var min: int = fmod(last_lap_time_usec / 1000000, 60 * 60) / 60
	return "%02d:%02d:%03d" % [min, sec, msec]
