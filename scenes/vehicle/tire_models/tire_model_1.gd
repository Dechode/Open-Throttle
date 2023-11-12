class_name BaseTireModel
extends Resource

const TIRE_WEAR_CURVE = preload("res://resources/tire_wear_curve.tres")
const TIRE_TEMP_CURVE = preload("res://resources/tire_temp_curve.tres")

@export var tire_stiffness := 0.25
@export var tire_width := 0.225
@export var tire_radius := 0.3
@export var tire_rated_pressure := 2.0

@export var lateral_buildup := Curve.new()
@export var longitudinal_buildup := Curve.new()

@export var lateral_falloff := Curve.new()
@export var longitudinal_falloff := Curve.new()

@export var load_sens0 := 1.5
@export var load_sens1 := 0.9
@export var tire_rated_load := 6000.0 # This should probably be calculated from tire input parameters?

# Possible input parameters for tire model

#var tire_pressure := 2.0
#var tire_ratio := 0.5
#var tire_rim_size := 16.0
#var camber := 0.0 # Camber angle in degrees

var tire_wear := 0.0
var load_sensitivity := 1.0
var tire_mass := 15.0

var tire_temperature := 20.0
var max_tire_temperature := 130.0


var peak_sa := 0.12
var peak_sr := 0.09


# Override this
func _get_forces(_normal_load: float, _total_mu: float, _grip: float, _contact_patch := 0.0, 
				_slip := Vector2.ZERO, _stiff := Vector2.ZERO,
				_cornering_stiff := Vector2.ZERO) -> Vector3:
	
	var mu := _total_mu
	
	var load_factor := _normal_load / tire_rated_load
	var peak_sa_deg: float = lerp(12.0, 3.0, tire_stiffness)
	var delta_sa_deg: float = lerp(4.0, 0.8, tire_stiffness)
	
	var sa0 := peak_sa_deg + 0.5 * delta_sa_deg
	var sa1 := peak_sa_deg - 0.5 * delta_sa_deg
	peak_sa = deg_to_rad(lerp(sa1, sa0, load_factor))
	peak_sr = peak_sa * 0.5
	
	var normalised_sr := _slip.y / peak_sr
	var normalised_sa := _slip.x / peak_sa
	var resultant_slip := sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
#
	var sr_modified := resultant_slip * peak_sr
	var sa_modified := resultant_slip * peak_sa
	
	var tire_forces := Vector3.ZERO
	
	if abs(_slip.x) < peak_sa:
		tire_forces.x = lateral_buildup.sample_baked(resultant_slip) * sign(_slip.x)
	else:
		tire_forces.x = lateral_falloff.sample_baked(sa_modified - peak_sa) * sign(_slip.x)
		
	if abs(_slip.y) < peak_sr:
		tire_forces.y = longitudinal_buildup.sample_baked(resultant_slip) * sign(_slip.y)
	else:
		tire_forces.y = longitudinal_falloff.sample_baked(sr_modified - peak_sr) * sign(_slip.y)
	
	tire_forces *= mu * _normal_load * load_sensitivity
	
	if resultant_slip != 0:
		tire_forces.x *= abs(normalised_sa / resultant_slip)
		tire_forces.y *= abs(normalised_sr / resultant_slip)
		
	var pneumatic_trail = get_pneumatic_trail(_slip.x, _cornering_stiff.x, _grip)
	tire_forces.z = tire_forces.x * pneumatic_trail
	return tire_forces


func update_tire_forces(_slip: Vector2, _normal_load: float, _surface_mu: float) -> Vector3:
	var stiff_vec := get_tire_stiffness()
	var contact_patch := get_contact_patch_length()
	var cornering_stiffness := Vector2.ZERO
	cornering_stiffness = 0.5 * stiff_vec * (contact_patch * contact_patch)
	
	var wear_mu := TIRE_WEAR_CURVE.sample_baked(tire_wear)
	var tire_temp_scalar := tire_temperature / max_tire_temperature
	var temp_mu := TIRE_TEMP_CURVE.sample_baked(tire_temp_scalar)
	load_sensitivity = update_load_sensitivity(_normal_load)
	var mu := _surface_mu * wear_mu * temp_mu #* load_sensitivity
	var grip := _normal_load * mu
	
	peak_sa = clamp(grip / cornering_stiffness.x, 0.04, 1.0)
	peak_sr = clamp(grip / cornering_stiffness.y, 0.01, 1.0)
	
	return _get_forces(_normal_load, mu, grip, contact_patch, _slip,
						stiff_vec, cornering_stiffness)


func update_tire_wear(prev_wear: float, friction_power: float, delta: float) -> float:
	# From Speed Dreams wiki: https://sourceforge.net/p/speed-dreams/wiki/TireTempDeg
	tire_wear = prev_wear
	var wear_rate := 0.000000015
	var delta_wear := clampf(friction_power * wear_rate * delta, -0.1, 0.1)
	tire_wear += delta_wear
	return tire_wear


func update_tire_temps(prev_temp: float, friction_power: float, speed: float, 
						delta: float, ambient_temp := 20.0) -> float:
	# From Speed Dreams wiki: https://sourceforge.net/p/speed-dreams/wiki/TireTempDeg/
	# dT/SimDeltaTime = P * heatingm - aircoolm * (1 + speedcoolm * v) * (T-Tair)
	var specific_heat_capacity := 1000.0
	var effective_heat_capacity := specific_heat_capacity * tire_mass
	var heating_multiplier := 1 / effective_heat_capacity
	var tire_area := 2 * PI * tire_radius * tire_width
	var air_cooling_multiplier := 10.0 * tire_area / specific_heat_capacity
	var speed_cooling_multiplier :=  0.10
	
	var heating := friction_power * heating_multiplier
	var cooling: float = air_cooling_multiplier * (1 + speed_cooling_multiplier * abs(speed))
	
	var delta_temp := heating - cooling * (prev_temp - ambient_temp)
	delta_temp *= delta
	delta_temp = clamp(delta_temp, -0.2, 0.2)
	
	prev_temp += delta_temp
	tire_temperature = prev_temp
	return tire_temperature


func update_load_sensitivity(normal_load: float) -> float:
	load_sensitivity = lerpf(load_sens0, load_sens1, normal_load / tire_rated_load)
	load_sensitivity = clampf(load_sensitivity, 0.1, 4.0)
	return load_sensitivity


func get_tire_stiffness() -> Vector2:
	# Returns Vector2 where x is lateral stiffness and y is tangential stiffness
	var stiffness := Vector2.ZERO
	stiffness = Vector2.ONE * (1_500_000 + 5_000_000 * tire_stiffness)
	return stiffness


func get_contact_patch_length() -> float:
	# TODO Make load and possible pressure dependant?
	return 0.5 * tire_radius


func get_pneumatic_trail(slip_angle: float, cornering_stiff: float, grip: float) -> float:
	var cp := get_contact_patch_length()
	var tp0 := cp / 6
	var lf := 1 / grip
	var tp := 0.0
	var alpha_si := atan(3 / (cornering_stiff * lf))
	if abs(slip_angle) < alpha_si:
		tp = tp0 - tp0 * cornering_stiff / 3 * lf * tan(slip_angle)
	return tp
