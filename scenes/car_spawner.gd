class_name CarSpawner
extends Node3D

enum DRIVER_TYPE {
	NO_DRIVER = 0,
	PLAYER,
	AI,
}

var grid: Array[Marker3D] = []


func _ready():
	for child in get_children():
		if child is Marker3D:
			grid.append(child)
	
	if RaceControl.grid.size() > self.grid.size():
		push_warning("No more spawn points in grid")
	else:
		var count = 0
		for car in RaceControl.grid:
			add_car(car, count)
			count += 1


func add_car(car_dict, grid_id):
	if car_dict.car_path == "":
		push_warning("Car path is empty")
		return
	
#	print_debug("car path = %s" % car_path)
	var car = load(car_dict.car_path).instantiate()
	if car_dict.driver_type == DRIVER_TYPE.PLAYER:
		for child in car.get_children():
			if child is BaseCar:
				child.add_child(load("res://scenes/drivers/player_driver.tscn").instantiate())
				var driver = PlayerDriver.new()
				child.set_driver(driver)
				
	grid[grid_id].add_child(car)
	
