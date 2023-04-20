class_name CarSetupMenu
extends TabContainer

#var car_setup: CarParameters


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Suspension/VBoxContainer/FrontSuspAntiRollRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_fl.anti_roll
	$Suspension/VBoxContainer/FrontSuspBumpRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_fl.bump
	$Suspension/VBoxContainer/FrontSuspReboundRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_fl.rebound
	$Suspension/VBoxContainer/FrontSuspLength/Slider.value = SessionManager.player_car_setup.wheel_params_fl.spring_length
	$Suspension/VBoxContainer/FrontSuspLength/Label2.text = str(SessionManager.player_car_setup.wheel_params_fl.spring_length)
	$Suspension/VBoxContainer/FrontSuspSpringRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_fl.spring_stiffness
	
	$Suspension/VBoxContainer/RearSuspAntiRollRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_bl.anti_roll
	$Suspension/VBoxContainer/RearSuspBumpRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_bl.bump
	$Suspension/VBoxContainer/RearSuspReboundRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_bl.rebound
	$Suspension/VBoxContainer/RearSuspLength/Slider.value = SessionManager.player_car_setup.wheel_params_bl.spring_length
	$Suspension/VBoxContainer/RearSuspLength/Label2.text = str(SessionManager.player_car_setup.wheel_params_bl.spring_length)
	$Suspension/VBoxContainer/RearSuspSpringRate/SpinBox.value = SessionManager.player_car_setup.wheel_params_bl.spring_stiffness

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_front_spring_length_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.spring_length = value
	SessionManager.player_car_setup.wheel_params_fr.spring_length = value
	$Suspension/VBoxContainer/FrontSuspLength/Label2.text = str(value)


func _on_front_spring_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.spring_stiffness = value
	SessionManager.player_car_setup.wheel_params_fr.spring_stiffness = value


func _on_front_bump_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.bump = value
	SessionManager.player_car_setup.wheel_params_fr.bump = value


func _on_front_rebound_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.rebound = value
	SessionManager.player_car_setup.wheel_params_fr.rebound = value


func _on_front_anti_roll_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.anti_roll = value
	SessionManager.player_car_setup.wheel_params_fr.anti_roll = value


func _on_rear_spring_length_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.spring_length = value
	SessionManager.player_car_setup.wheel_params_br.spring_length = value
	$Suspension/VBoxContainer/RearSuspLength/Label2.text = str(value)


func _on_rear_spring_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.spring_stiffness = value
	SessionManager.player_car_setup.wheel_params_br.spring_stiffness = value


func _on_rear_bump_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.bump = value
	SessionManager.player_car_setup.wheel_params_br.bump = value


func _on_rear_rebound_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.rebound = value
	SessionManager.player_car_setup.wheel_params_br.rebound = value


func _on_rear_anti_roll_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.anti_roll = value
	SessionManager.player_car_setup.wheel_params_br.anti_roll = value


