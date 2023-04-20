extends Button

signal car_selected

@export var car_path := "" # (String, FILE)
@export var is_player := true

func _on_car_button_pressed():
	var driver_type := 0
	var car = load(car_path).instantiate() # TODO pass reference to the car in RaceControl and CarSpawner
	var car_params = CarParameters.new()
	
	for child in car.get_children():
		if child is BaseCar:
			car_params = child.car_params
		else:
			push_warning("car_path is not a path to a valid car scene")
			return
	
	if is_player:
		SessionManager.player_car_path = car_path
		SessionManager.player_car_setup = car_params
		driver_type = 1
	
	car_selected.emit()
	RaceControl.add_to_grid(car_path, driver_type, 1)
	

