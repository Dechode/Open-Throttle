extends Node3D
class_name Aero

@export var max_lift_coeff: float = 0.2
@export var max_drag_coeff: float = 1.0

@export var lift_coeff_curve: Curve 
@export var drag_coeff_curve: Curve 

@export var wingspan: float = 1.7
@export var chord: float = 0.2

var angle_of_attack: float = 5.0

var local_vel: Vector3 = Vector3.ZERO
var prev_pos: Vector3 = Vector3.ZERO

var drag_force: float = 0.0
var lift_force: float = 0.0

@onready var car: RigidBody3D = get_parent()

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	local_vel = (global_transform.origin - prev_pos) / delta * global_transform.basis
	prev_pos = global_transform.origin
	
	var z_vel = -local_vel.z
	
	var planar_vect = Vector2(local_vel.y, local_vel.z).normalized()
	angle_of_attack = rad_to_deg(asin(clamp(-planar_vect.x, -1, 1)))
	
	var angle_factor = abs(angle_of_attack) / 30
	var cl = lift_coeff_curve.sample_baked(angle_factor) * max_lift_coeff * sign(angle_of_attack)
	var cd = drag_coeff_curve.sample_baked(angle_factor) * max_drag_coeff
	
	var frontal_area = wingspan * chord
	var vel2 = local_vel.length_squared()
	
	lift_force = 0.5 * frontal_area * z_vel * z_vel * car.air_density * cl if abs(z_vel) < 1000 else 0
	drag_force = 0.5 * vel2 * frontal_area * car.air_density * cd if vel2 < 100000 else 0
	
	var offset = global_transform.origin - car.global_transform.origin
#	print(offset)
	car.apply_central_force(-local_vel.normalized() * drag_force)
	car.apply_force(offset, global_transform.basis.y * lift_force)
