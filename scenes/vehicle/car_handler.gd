extends Node3D

enum DRIVER_TYPE {
	NO_DRIVER = 0,
	PLAYER,
	AI,
}

var car_id = -1
var car_setup: CarSetup = null
var default_driver = DRIVER_TYPE.NO_DRIVER


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_driver(default_driver)
	
	if car_setup:
		update_setup()

func add_driver(driver):
	if driver == DRIVER_TYPE.PLAYER:
		var driver_inst = load("res://scenes/drivers/player_driver.tscn").instantiate()
		for child in get_children():
			if child is BaseCar:
				child.add_child(driver_inst)
	else:
		$RigidBodyCar.brake_input = 1.0


func update_setup():
	$RigidBodyCar.front_brake_bias = car_setup.front_brake_bias
	$RigidBodyCar.center_split_fr = car_setup.center_split
	
	$RigidBodyCar/Wheel_bl.spring_stiffness = car_setup.suspension_spring_rate_bl
	$RigidBodyCar/Wheel_br.spring_stiffness = car_setup.suspension_spring_rate_br
	$RigidBodyCar/Wheel_fl.spring_stiffness = car_setup.suspension_spring_rate_fl
	$RigidBodyCar/Wheel_fr.spring_stiffness = car_setup.suspension_spring_rate_fr
	
	$RigidBodyCar/Wheel_bl.bump = car_setup.suspension_bump_rate_bl
	$RigidBodyCar/Wheel_br.bump = car_setup.suspension_bump_rate_br
	$RigidBodyCar/Wheel_fl.bump = car_setup.suspension_bump_rate_fl
	$RigidBodyCar/Wheel_fr.bump = car_setup.suspension_bump_rate_fr
	
	$RigidBodyCar/Wheel_bl.rebound = car_setup.suspension_rebound_rate_bl
	$RigidBodyCar/Wheel_br.rebound = car_setup.suspension_rebound_rate_br
	$RigidBodyCar/Wheel_fl.rebound = car_setup.suspension_rebound_rate_fl
	$RigidBodyCar/Wheel_fr.rebound = car_setup.suspension_rebound_rate_fr
	
	$RigidBodyCar/Wheel_bl.anti_roll = car_setup.anti_roll_bar_rear
	$RigidBodyCar/Wheel_br.anti_roll = car_setup.anti_roll_bar_rear
	$RigidBodyCar/Wheel_fl.anti_roll = car_setup.anti_roll_bar_front
	$RigidBodyCar/Wheel_fr.anti_roll = car_setup.anti_roll_bar_front
	
	$RigidBodyCar/Wheel_bl.spring_length = car_setup.rear_suspension_length
	$RigidBodyCar/Wheel_br.spring_length = car_setup.rear_suspension_length
	$RigidBodyCar/Wheel_fl.spring_length = car_setup.front_suspension_length
	$RigidBodyCar/Wheel_fr.spring_length = car_setup.front_suspension_length
