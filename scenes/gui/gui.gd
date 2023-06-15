extends Control


@onready var speed_label = $Essentials/VBoxContainer/Speedlabel
@onready var gear_label = $Essentials/VBoxContainer/GearLabel
@onready var rpm_label = $Essentials/VBoxContainer/RpmLabel
@onready var fuel_label = $Essentials/VBoxContainer/FuelLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_label.text = "Speed = %d" % int(VehicleAPI.car.speedo)
	gear_label.text = "gear = %d" % VehicleAPI.car.drivetrain.selected_gear
	rpm_label.text = "RPM = %d" % int(VehicleAPI.car.rpm)
	fuel_label.text = "Fuel = %3.2f" % VehicleAPI.car.fuel
