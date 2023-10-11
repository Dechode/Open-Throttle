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


func _ready() -> void:
	process_children()
	add_child(lighting_scene.instantiate())


func process_children():
	var children := get_children()
	children.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	
	for child in children:
		if child.name.begins_with("gridspawn-"):
			print_debug("Found grid spawn point")
		
		elif child.name.begins_with("pitspawn-"):
			print_debug("Found pit spawn point")
		
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
