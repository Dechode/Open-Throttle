extends Control

@onready var temp_colors := [$Panel/TireFL/TemperatureColor, $Panel/TireFR/TemperatureColor,
							$Panel/TireBL/TemperatureColor, $Panel/TireBR/TemperatureColor]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var wears: Array = VehicleAPI.get_tire_wear()
	var temps: Array = VehicleAPI.get_tire_temps()
	
	$Panel/TireFL/TireWear.text = "%3.2f %%" % (wears[0] * 100)
	$Panel/TireFR/TireWear.text = "%3.2f %%" % (wears[1] * 100)
	$Panel/TireBL/TireWear.text = "%3.2f %%" % (wears[2] * 100)
	$Panel/TireBR/TireWear.text = "%3.2f %%" % (wears[3] * 100)
	
	for i in range(4):
		var temp: float = temps[i]
		if temp < 65:
			var amount = clamp(temp / 65.0, 0, 1)
			temp_colors[i].color = lerp(Color.BLUE, Color.LIME_GREEN, amount)
		else:
			var amount = clamp((temp-65) / (130.0-65), 0, 1)
			temp_colors[i].color = lerp(Color.LIME_GREEN, Color.RED, amount)
	
	$Panel/TireFL/TemperatureColor/TemperatureLabel.text = "%2.1f °C" % temps[0]
	$Panel/TireFR/TemperatureColor/TemperatureLabel.text = "%2.1f °C" % temps[1]
	$Panel/TireBL/TemperatureColor/TemperatureLabel.text = "%2.1f °C" % temps[2]
	$Panel/TireBR/TemperatureColor/TemperatureLabel.text = "%2.1f °C" % temps[3]
	
	

