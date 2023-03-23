extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var wear_bl = VehicleAPI.tires[0].tire_wear
	var wear_br = VehicleAPI.tires[1].tire_wear
	var wear_fl = VehicleAPI.tires[2].tire_wear
	var wear_fr = VehicleAPI.tires[3].tire_wear
	
	$Panel/TireFL/TireWear.text = str(snapped(wear_fl * 100, 0.01))
	$Panel/TireFR/TireWear.text = str(snapped(wear_fr * 100, 0.01))
	$Panel/TireBL/TireWear.text = str(snapped(wear_bl * 100, 0.01))
	$Panel/TireBR/TireWear.text = str(snapped(wear_br * 100, 0.01))

