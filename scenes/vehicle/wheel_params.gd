class_name WheelSuspensionParameters
extends Resource

@export var tire_model := BaseTireModel.new()
@export var spring_length := 0.15
@export var spring_stiffness := 45000.0
@export var bump_ls := 10000.0
@export var bump_hs := 7500.0
@export var rebound_ls := 11000.0
@export var rebound_hs := 8000.0
@export var lo_hi_threshold := 100.0
@export var wheel_mass := 20.0 # Including brake disc and drive shaft
@export var ackermann := 0.15
@export var anti_roll := 50.0
