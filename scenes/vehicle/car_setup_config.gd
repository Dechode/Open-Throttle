class_name CarSetup
extends Resource

@export_range(0.0, 1.0, 0.01) var front_brake_bias := 0.6

@export var front_suspension_length := 0.15
@export var rear_suspension_length := 0.15
 
@export var suspension_spring_rate_fl := 1000000.0
@export var suspension_spring_rate_fr := 1000000.0
@export var suspension_spring_rate_bl := 700000.0
@export var suspension_spring_rate_br := 700000.0
 
@export var suspension_bump_rate_fl := 8000.0
@export var suspension_bump_rate_fr := 8000.0
@export var suspension_bump_rate_bl := 8000.0
@export var suspension_bump_rate_br := 8000.0
 
@export var suspension_rebound_rate_fl := 8000.0
@export var suspension_rebound_rate_fr := 8000.0
@export var suspension_rebound_rate_bl := 8000.0
@export var suspension_rebound_rate_br := 8000.0
 
@export var anti_roll_bar_front := 100.0
@export var anti_roll_bar_rear := 100.0
 
@export_range(0.0, 1.0, 0.01) var center_split := 0.5

@export var front_toe_in := 0.0
@export var rear_toe_in := 0.0
 
@export var tire_stiffness_fl := 0.5
@export var tire_stiffness_fr := 0.5
@export var tire_stiffness_bl := 0.5
@export var tire_stiffness_br := 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
