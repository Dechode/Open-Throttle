extends Node

var track_path := ""
var player_car_path := ""
var player_car_setup: CarParameters
var time_of_day := 12.00
var time_multiplier := 10.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_car_setup = CarParameters.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func set_track_path(path):
	track_path = path
