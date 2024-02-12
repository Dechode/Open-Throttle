class_name CameraSystem
extends Node3D

var lerp_speed = 10.0

var cam_targets := []
var selected_cam := 0

@onready var camera: Camera3D = $Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.fov = OptionsManager.get_config_value("fov")
	
	for child in get_children():
		if not child is CamTargets:
			continue
		cam_targets.append(child)
		camera.set_as_top_level(true)
		camera.global_transform.origin = cam_targets[selected_cam].get_cam_pos_target()


func _unhandled_input(event):
	if event.is_action_pressed("change_camera") or event.is_action_pressed("change_camera_secondary") :
		selected_cam += 1
		if selected_cam >= cam_targets.size():
			selected_cam = 0
		camera.global_transform.origin = cam_targets[selected_cam].get_cam_pos_target()
		camera.set_as_top_level(not cam_targets[selected_cam].static_camera)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	if cam_targets[selected_cam].is_static():
		camera.look_at(cam_targets[selected_cam].get_cam_look_at_target(), cam_targets[selected_cam].global_transform.basis.y)
		return
	lerp_speed = cam_targets[selected_cam].lerp_speed
	var target_pos = cam_targets[selected_cam].get_cam_pos_target()
	var cam_pos = camera.global_transform.origin
	camera.global_transform.origin = cam_pos.lerp(target_pos, delta * lerp_speed)
	camera.look_at(cam_targets[selected_cam].get_cam_look_at_target(), Vector3.UP)

