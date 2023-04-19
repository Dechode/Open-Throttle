extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var wears: Array = VehicleAPI.get_tire_wear()
	
	$Panel/TireFL/TireWear.text = "%3.2f %%" % (wears[0] * 100)
	$Panel/TireFR/TireWear.text = "%3.2f %%" % (wears[1] * 100)
	$Panel/TireBL/TireWear.text = "%3.2f %%" % (wears[2] * 100)
	$Panel/TireBR/TireWear.text = "%3.2f %%" % (wears[3] * 100)

