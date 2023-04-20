extends Node

const MAX_CARS = 32

var grid := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_to_grid(car_path, driver_type, pos):
	if grid.size() >= MAX_CARS:
		push_warning("Grid is full, cant add more cars ")
		return
	
	if pos < 1:
		push_warning("pos cant be lower than 1")
		return
	
	if pos > grid.size():
		grid.resize(pos)
	
	var car := {
	"car_path": car_path,
	"driver_type": driver_type,
	}
	
	grid[pos-1] = car
