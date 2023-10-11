class_name GameLevel
extends Node3D

const lighting_scene = preload("res://scenes/lighting.tscn")

enum LEVEL_TYPE {
	RACE_TRACK,
	RALLY_STAGE,
	OTHER,
}

@export var level_name := "Default"
@export var level_type := LEVEL_TYPE.RACE_TRACK

var pit_spawns := []
var grid_spawns := []

var car_spawner := CarSpawner.new()


func _ready() -> void:
	process_children()
	reset_spawn_points()
	add_child(lighting_scene.instantiate())
	car_spawner.reset_grid()


func process_children():
	var children := get_children()
	children.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	
	for child in children:
		if child.name.begins_with("gridspawn-"):
			print_debug("Found grid spawn point")
			grid_spawns.append(child)
		
		elif child.name.begins_with("pitspawn-"):
			print_debug("Found pit spawn point")
			pit_spawns.append(child)
		
		elif child.name.begins_with("tarmac-"):
			print_debug("Found tarmac")
			for grand_child in child.get_children():
				if grand_child is StaticBody3D:
					grand_child.add_to_group("tarmac", true)
		
		elif child.name.begins_with("gravel-"):
			print_debug("Found gravel")
			for grand_child in child.get_children():
				if grand_child is StaticBody3D:
					grand_child.add_to_group("gravel", true)
		
		elif child.name.begins_with("snow-"):
			print_debug("Found snow")
			for grand_child in child.get_children():
				if grand_child is StaticBody3D:
					grand_child.add_to_group("snow", true)
		
		elif child.name.begins_with("sand-"):
			print_debug("Found sand")
			for grand_child in child.get_children():
				if grand_child is StaticBody3D:
					grand_child.add_to_group("sand", true)
		
		elif child.name.begins_with("grass-"):
			print_debug("Found grass")
			for grand_child in child.get_children():
				if grand_child is StaticBody3D:
					grand_child.add_to_group("grass", true)
		
	if grid_spawns.size() == 0 and pit_spawns.size() == 0:
		push_warning("No spawn points found")


func reset_spawn_points():
	# TODO Make spawn point based on game mode / state
	for point in grid_spawns:
		car_spawner.add_spawn_point(point)
