extends Button

signal car_selected

@export_file var car_path := "" # (String, FILE)
@export var is_player := true

func _on_car_button_pressed():
	var car_scene = load(car_path).instantiate() 
	var car_params = CarParameters.new()
	var car: BaseCar
	for child in car_scene.get_children():
		if child is BaseCar:
			car = child
			car_params = child.car_params
		else:
			push_warning("car_path is not a path to a valid car scene")
			return
	
	if is_player:
		SessionManager.player_car_path = car_path
		SessionManager.player_car_setup = car_params
		car.driver = PlayerDriver.new()
	
	car_selected.emit()
	RaceControl.add_to_grid(car_scene, 1)
	

