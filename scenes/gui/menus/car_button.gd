extends Button

@export var car_path := "" # (String, FILE)
@export var is_player := true

func _on_car_button_pressed():
	var car := CarDriverPair.new()
	car.car_path = car_path
	if is_player:
		SessionManager.player_car_path = car_path
		car.driver_type = 1
	
	# TODO Add cars with their positions somehow
	RaceControl.add_to_grid(car, 1)
	

