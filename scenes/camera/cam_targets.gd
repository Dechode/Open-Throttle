class_name CamTargets
extends Node3D

@export var lerp_speed := 20.0
@export var static_camera := false
var look_at_pos := Vector3.ZERO
var target_pos := Vector3.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
	look_at_pos = $CameraLookAtTarget.global_transform.origin
	target_pos = $CameraPosTarget.global_transform.origin


func _physics_process(delta):
	look_at_pos = $CameraLookAtTarget.global_transform.origin
	target_pos = $CameraPosTarget.global_transform.origin


func get_cam_look_at_target():
	return look_at_pos


func get_cam_pos_target():
	return target_pos


func is_static():
	return static_camera

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
