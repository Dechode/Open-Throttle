extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Panel/VBoxContainer/ThrottleInput.value = InputManager.get_throttle_input() * 100
	$Panel/VBoxContainer/BrakeInput.value = InputManager.get_brake_input() * 100
	$Panel/VBoxContainer/ClutchInput.value = InputManager.get_clutch_input() * 100
	var steer = InputManager.get_steering_input() * -100
	if steer < 0:
		$Panel/VBoxContainer/SteeringInput/SteeringInputLeft.value = InputManager.get_steering_input() * 100
		$Panel/VBoxContainer/SteeringInput/SteeringInputRight.value = 0
	else:
		$Panel/VBoxContainer/SteeringInput/SteeringInputRight.value = InputManager.get_steering_input() * -100
		$Panel/VBoxContainer/SteeringInput/SteeringInputLeft.value = 0
	#print((Input.get_action_strength("SteerRight") - Input.get_action_strength("SteerLeft")) * 100)


