class_name OptionsConfig
extends Resource

@export var config := {
"input_map": {},
"steer_left_inverted": 0,
"steer_left_inverted_sec": 0,
"steer_right_inverted": 0,
"steer_right_inverted_sec": 0,
"throttle_minus_one_to_one": 0,
"throttle_minus_one_to_one_sec": 0,
"throttle_inverted": false,
"throttle_inverted_sec": false,
"brake_minus_one_to_one": 0,
"brake_minus_one_to_one_sec": 0,
"brake_inverted": false,
"brake_inverted_sec": false,
"clutch_minus_one_to_one": 0,
"clutch_minus_one_to_one_sec": 0,
"clutch_inverted": false,
"clutch_inverted_sec": false,
"handbrake_minus_one_to_one": 0,
"handbrake_minus_one_to_one_sec": 0,
"handbrake_inverted": false,
"handbrake_inverted_sec": false,
"aspect_ratio" : 1,
"resolution" : 2, # index to resolutions array
"fullscreen" : false,
"vsync" : true,
"steering_interpolation" : true,
"master_audio_vol" : 0.5,
"shadows" : true,
"ffb_enabled" : false,
"ffb_gain" : 0.0,
"ffb_min_force" : 0.0,
"ffb_front_force": 1.0,
"ffb_rear_force": 0.05,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
