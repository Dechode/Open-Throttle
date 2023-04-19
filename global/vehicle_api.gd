extends Node

var car: BaseCar


func _ready():
	pass


func get_tire_wear():
	var wear_fl: float = car.wheel_fl.tire_wear
	var wear_fr: float = car.wheel_fr.tire_wear
	var wear_bl: float = car.wheel_bl.tire_wear
	var wear_br: float = car.wheel_br.tire_wear
	
	return [wear_fl, wear_fr, wear_bl, wear_br]
