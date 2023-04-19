class_name BaseTireModel
extends Resource

const TIRE_WEAR_CURVE = preload("res://resources/tire_wear_curve.tres")

@export var tire_stiffness := 0.5
@export var tire_width := 0.225
@export var tire_radius := 0.3
@export var tire_rated_load := 7000

# Possible input parameters for tire model
#export var tire_rated_pressure := 2.0


var tire_wear := 0.0
var load_sensitivity := 1.0

var peak_sa := 0.1
var peak_sr := 0.1


# Possible variables for force calculations
#var tire_temperature := 280.0 # Kelvin
#var tire_pressure := 2.0
#var tire_ratio := 0.5
#var tire_rim_size := 16.0
#var pneumatic_trail = 0.03


# Override this
func update_tire_forces(_slip: Vector2, _normal_load: float, _surface_mu: float) -> Vector3:
	return Vector3.ZERO


func update_tire_wear(delta: float, slip: Vector2, normal_load: float, mu: float, prev_wear: float):
	var larger_slip = max(abs(slip.x), abs(slip.y))
	prev_wear += larger_slip * mu * delta * normal_load  / (5000000 + tire_stiffness * 10000000)
	prev_wear = clamp(prev_wear, 0 ,1)
	return prev_wear


func update_load_sensitivity(normal_load: float) -> float:
	var width_factor = tire_width / 0.225
	var max_mu = 2.0 - tire_stiffness * 0.9 + width_factor * 0.5 - 0.5
	var min_mu = 0.6 + tire_stiffness * 0.35 + width_factor * 0.5 - 0.5
	var load_factor = normal_load / tire_rated_load
	load_factor = clamp(load_factor, 0.0, 1.0)
	load_sensitivity = clamp(min_mu + (1 - load_factor) * (max_mu - min_mu), min_mu, max_mu)
#	print_debug(load_sensitivity)
	return load_sensitivity
