extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DirectionalLight3D.shadow_enabled = OptionsManager.get_config_value("shadows")
