extends Decal

var active := false:
	set(value):
		active = value
		visible = value
		if value:
			$TireMarkTimer.start()


func _on_tire_mark_timer_timeout() -> void:
	active = false
