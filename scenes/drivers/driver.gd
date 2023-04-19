class_name Driver
extends Node3D

var steering_input := 0.0
var throttle_input := 0.0
var brake_input := 1.0
var clutch_input := 0.0
var handbrake_input := 0.0
var steer_speed := 5.0

var driver_number := -1
var driver_name := ""

@onready var car = get_parent()

#func _ready() -> void:
#	VehicleAPI.cars.append(car)
#	driver_number = VehicleAPI.cars.size() - 1
	
