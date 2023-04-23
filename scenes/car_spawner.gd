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


func add_car(car, grid_id):
	for child in car.get_children():
		if not child is BaseCar:
			continue
			
		if child.driver is PlayerDriver:
			print_debug("Driver is PlayerDriver")
#			child.add_child(load("res://scenes/gui/gui.tscn").instantiate())
			var driver = PlayerDriver.new()
			child.set_driver(driver)
			
	grid[grid_id].add_child(car)
	
