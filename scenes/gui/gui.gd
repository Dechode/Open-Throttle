extends Control


@onready var car = get_parent().get_parent()
@onready var speed_label = $Essentials/VBoxContainer/Speedlabel
@onready var gear_label = $Essentials/VBoxContainer/GearLabel
@onready var rpm_label = $Essentials/VBoxContainer/RpmLabel
@onready var fuel_label = $Essentials/VBoxContainer/FuelLabel

# TODO Use VehicleAPI to get the properties
#func _ready() -> void:
#	car = VehicleAPI.car


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_label.text = str("Speed = ") + str(int(car.speedo))
	gear_label.text = str("gear = ") + str(car.selected_gear)
	rpm_label.text = str("RPM = ") + str(int(car.rpm))
	fuel_label.text = "Fuel = %3.2f" % car.fuel
