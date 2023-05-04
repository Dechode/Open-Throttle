extends Node3D


var time_of_day := 24.00
var time_multiplier := 1000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_of_day = SessionManager.time_of_day
	time_multiplier = SessionManager.time_multiplier
	$DirectionalLight3D.shadow_enabled = OptionsManager.get_config_value("shadows")
	var mult := 1.0 / 86400 * time_multiplier
	print_debug(mult)
	$AnimationPlayer.play("day_night_cycle", -1, mult)
	$AnimationPlayer.seek(wrapf((time_of_day / 24) + 0.25, 0.0, 1.0))


#func _process(delta: float) -> void:
#	time_of_day = Time.get_ticks_msec() * time_multiplier
