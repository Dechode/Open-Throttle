extends Control


var car: BaseCar
@onready var speed_label = $Essentials/VBoxContainer/Speedlabel
@onready var gear_label = $Essentials/VBoxContainer/GearLabel
@onready var rpm_label = $Essentials/VBoxContainer/RpmLabel
@onready var fuel_label = $Essentials/VBoxContainer/FuelLabel

# TODO Use VehicleAPI to get the properties, this itself wont
func _ready() -> void:
	VehicleAPI.connect("car_changed", set_car)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_label.text = "Speed = %d" % int(car.speedo)
	gear_label.text = "gear = %d" % car.selected_gear
	rpm_label.text = "RPM = %d" % int(car.rpm)
	fuel_label.text = "Fuel = %3.2f" % car.fuel


func set_car(new_car):
	car = new_car
