class_name WheelSuspensionParameters
extends Resource

@export var tire_model := BaseTireModel.new()
@export var spring_length := 0.15
@export var spring_stiffness := 50.0
@export var bump_ls := 6.0
@export var bump_hs := 4.0
@export var rebound_ls := 7.0
@export var rebound_hs := 5.0
@export var lo_hi_threshold := 100.0
@export var wheel_mass := 20.0 # Including brake disc and drive shaft
@export var anti_roll := 5.0

var ackermann := 0.15
