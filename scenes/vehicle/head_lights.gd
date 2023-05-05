class_name HeadLights
extends Node3D

func _ready() -> void:
	$SpotLight3D.shadow_enabled = OptionsManager.get_config_value("shadows")
	$SpotLight3D2.shadow_enabled = OptionsManager.get_config_value("shadows")


func toggle_lights():
	$SpotLight3D.light_energy = 10 if $SpotLight3D.light_energy == 0 else 0 
	$SpotLight3D2.light_energy = 10 if $SpotLight3D2.light_energy == 0 else 0
