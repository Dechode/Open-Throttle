extends Control

@onready var fps_label = $Info/FPS
@onready var draw_calls_label = $Info/DrawCalls
@onready var objects_label = $Info/Objects


func _process(delta: float) -> void:
	fps_label.text = "FPS: %3.0f" % Performance.get_monitor(Performance.TIME_FPS)
	draw_calls_label.text = "Draw Calls: %4.0f" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	objects_label.text = "Object Count: %5.0f" % Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
