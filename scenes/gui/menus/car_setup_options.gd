extends TabContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_front_spring_length_changed(value:float):
	SessionManager.car_setup.front_suspension_length = value


func _on_front_spring_rate_changed(value:float):
	SessionManager.car_setup.suspension_spring_rate_fl = value
	SessionManager.car_setup.suspension_spring_rate_fr = value


func _on_front_bump_rate_changed(value:float):
	SessionManager.car_setup.suspension_bump_rate_fl = value
	SessionManager.car_setup.suspension_bump_rate_fr = value


func _on_front_rebound_rate_changed(value:float):
	SessionManager.car_setup.suspension_rebound_rate_fl = value
	SessionManager.car_setup.suspension_rebound_rate_fr = value


func _on_front_anti_roll_changed(value:float):
	SessionManager.car_setup.anti_roll_bar_front = value


func _on_rear_spring_length_changed(value:float):
	SessionManager.car_setup.rear_suspension_length = value


func _on_rear_spring_rate_changed(value:float):
	SessionManager.car_setup.suspension_spring_rate_bl = value
	SessionManager.car_setup.suspension_spring_rate_br = value


func _on_rear_bump_rate_changed(value:float):
	SessionManager.car_setup.suspension_bump_rate_bl = value
	SessionManager.car_setup.suspension_bump_rate_br = value


func _on_rear_rebound_rate_changed(value:float):
	SessionManager.car_setup.suspension_rebound_rate_bl = value
	SessionManager.car_setup.suspension_rebound_rate_br = value


func _on_rear_anti_roll_changed(value:float):
	SessionManager.car_setup.anti_roll_bar_rear = value

