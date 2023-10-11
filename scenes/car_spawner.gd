class_name CarSpawner
extends Node3D

var spawn_points: Array[Node3D] = []


func _ready():
	spawn_points = get_grid()
	reset_grid()


func reset_grid():
	if RaceControl.grid.size() > spawn_points.size():
		push_warning("No more spawn points in spawn_points")
	else:
		var count = 0
		for car in RaceControl.grid:
			add_car(car, count)
			count += 1


func add_spawn_point(node: Node3D):
	if not node in spawn_points:
		spawn_points.append(node)


func get_grid():
	var res: Array[Node3D] = []
	
	for child in get_children():
		if child is Node3D:
			res.append(child)
	
	return res


func add_car(car, grid_id):
	for child in car.get_children():
		if not child is BaseCar:
			continue
			
		if child.driver is PlayerDriver:
			var driver = PlayerDriver.new()
			child.set_driver(driver)
			
	spawn_points[grid_id].add_child(car)
	
