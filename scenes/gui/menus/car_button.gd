extends Button

@export var car_path := "" # (String, FILE)
@export var is_player := true

func _on_car_button_pressed():
#	car.car_path = car_path
	var driver_type := 0
	if is_player:
		SessionManager.player_car_path = car_path
		driver_type = 1
	
	RaceControl.add_to_grid(car_path, driver_type, 1)
	

