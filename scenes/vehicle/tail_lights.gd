class_name TailLights
extends Node3D


func _ready() -> void:
	$SpotLight3D.shadow_enabled = OptionsManager.get_config_value("shadows")
	$SpotLight3D2.shadow_enabled = OptionsManager.get_config_value("shadows")


func set_brake_lights(braking):
	if $SpotLight3D.light_energy == 0 or $SpotLight3D2.light_energy == 0:
		return
	if braking:
		$SpotLight3D.light_energy = 10.0
		$SpotLight3D2.light_energy = 10.0
	else:
		$SpotLight3D.light_energy = 5.0
		$SpotLight3D2.light_energy = 5.0


func toggle_lights():
	$SpotLight3D.light_energy = 5 if $SpotLight3D.light_energy == 0 else 0 
	$SpotLight3D2.light_energy = 5 if $SpotLight3D2.light_energy == 0 else 0

