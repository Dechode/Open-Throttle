extends Panel

var total_laps := 0

func _ready() -> void:
	$HBoxContainer/VBoxContainer/Lap.text = "Lap: 0 / %d" % total_laps
	$HBoxContainer/VBoxContainer/LastLapTime.text = "Last Lap Time: 00:00:000"
	$HBoxContainer/VBoxContainer/CurLapTime.text = "Current: 00:00:000"
	
	var err = VehicleAPI.car.lap_timer.lap_finished.connect(_on_lap_finished)
	if err != OK:
		push_warning("Could not connect to lap finished signal")


func _process(delta: float) -> void:
	if VehicleAPI.car.lap_timer.lap > 0:
		var cur_lap_time: int = Time.get_ticks_usec() - VehicleAPI.car.lap_timer.lap_start_time_usec
		var lap_str: String = VehicleAPI.car.lap_timer.get_lap_time_str(cur_lap_time)
		$HBoxContainer/VBoxContainer/CurLapTime.text = "Current: %s" % lap_str


func _on_lap_finished():
	var lap := VehicleAPI.car.lap_timer.lap
	var last: String = "00:00:000"
	if lap > 1:
		var t := VehicleAPI.car.lap_timer.last_lap_time_usec
		last = VehicleAPI.car.lap_timer.get_lap_time_str(t)
#	print_debug("Lap %d finished" % lap)
	update_lap_info(lap, last, "00:00:000")


func update_lap_info(lap: int, last_lap_time: String, current: String) -> void:
	$HBoxContainer/VBoxContainer/Lap.text = "Lap: %d / %d" % [lap, total_laps]
	$HBoxContainer/VBoxContainer/LastLapTime.text = "Last Lap Time: %s" % last_lap_time
	$HBoxContainer/VBoxContainer/CurLapTime.text = "Current: %s" % current
