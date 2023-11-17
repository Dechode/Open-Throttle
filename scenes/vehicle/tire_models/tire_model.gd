class_name BaseTireModel
extends Resource

const TIRE_WEAR_CURVE = preload("res://resources/tire_wear_curve.tres")
const TIRE_TEMP_CURVE = preload("res://resources/tire_temp_curve.tres")

@export var tire_stiffness := 0.25
@export var thread_length := 1.0 ## mm
@export var tire_width := 0.225
@export var tire_ratio := 0.5
@export var tire_rated_pressure := 2.0
@export var tire_pressure := 2.0
@export var tire_rim_size := 15.0
@export var max_tire_temperature := 130.0

@export var lateral_buildup := Curve.new()
@export var longitudinal_buildup := Curve.new()

@export var lateral_falloff := Curve.new()
@export var longitudinal_falloff := Curve.new()

# These should probably be calculated from tire input parameters?
var load_sens0 := 1.5
var load_sens1 := 0.9

var tire_rated_load := 6000.0
var tire_radius := 0.3

#var camber := 0.0 # Camber angle in degrees

var tire_wear := 0.0
var load_sensitivity := 1.0
var tire_mass := 15.0

var tire_temperature := 20.0

var peak_sa := 0.12
var peak_sr := 0.09


func update_tire_forces(_slip: Vector2, _normal_load: float, _surface_mu: float) -> Vector3:
	var stiff_vec := get_tire_stiffness()
	var contact_patch := get_contact_patch_length()
	var cornering_stiffness := Vector2.ZERO
	cornering_stiffness = 0.5 * stiff_vec * (contact_patch * contact_patch)
	var rim := tire_rim_size * 2.54 * 0.01
	tire_radius = ((tire_width * tire_ratio * 2) + rim) * 0.5
	
	var springrate := get_springrate_sae()
	tire_rated_load = get_rated_load(springrate)
	
	calc_load_sensitivities(springrate)
	
	var wear_mu := TIRE_WEAR_CURVE.sample_baked(tire_wear)
	var tire_temp_scalar := tire_temperature / max_tire_temperature
	var temp_mu := TIRE_TEMP_CURVE.sample_baked(tire_temp_scalar)
	load_sensitivity = update_load_sensitivity(_normal_load)
	var mu := _surface_mu * wear_mu * temp_mu #* load_sensitivity
	var grip := _normal_load * mu
	
	var load_factor := _normal_load / tire_rated_load
	
	var basepeak := 4.5
	var widthpeak := -4.0
	var aspectpeak := 5.0
	var thread_reduction := 0.85
	var softness_gain := 1.05
	
	var base_elasticity := 0.2
	var width_elasticity := -0.1
	var aspect_elasticity := 0.2
	
	var slickness := thread_length / 1.8
	var slickness_peak := slickness * (thread_reduction - 1) + 1
	var softness := 1.0 - tire_stiffness
	var softness_peak := softness * (softness_gain - 1) + 1
	
	var peak_sa_min_deg := (basepeak + widthpeak * tire_width + aspectpeak * tire_ratio) * slickness_peak * softness_peak
	var peak_sa_max_deg := (1.0 + (base_elasticity + width_elasticity * tire_width + aspect_elasticity * tire_ratio)) * peak_sa_min_deg
	
	peak_sa = deg_to_rad(lerp(peak_sa_min_deg, peak_sa_max_deg, load_factor))
	peak_sr = peak_sa * 0.75
	
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
		
	var pneumatic_trail = get_pneumatic_trail(_slip.x, cornering_stiffness.x, grip)
	tire_forces.z = tire_forces.x * pneumatic_trail
	
	return tire_forces


func get_rated_load(springrate: float) -> float:
	var radius_compression_force := springrate * 0.12 * tire_radius
	var sidewall_compression_force := springrate * 0.11 * tire_width * tire_radius
	
	return 0.5 * radius_compression_force + 0.5 * sidewall_compression_force


func get_springrate_sae() -> float:
	var p := tire_rated_pressure * 100.0
	var sn := tire_width * 1000.0
	var od := tire_radius * 2 * 1000.0
	var kz := 0.00028 * p * sqrt((-0.004 * tire_ratio +  1.03) * sn * od) + 3.45
	return kz * 9.81 * 1000.0


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


func calc_load_sensitivities(springrate: float):
	var min_mu0 := 1.2
	var max_mu0 := 3.0
	var min_mu_slope := -0.0000015
	var max_mu_slope := -0.0000135
	
	load_sens0 = lerpf(max_mu0, min_mu0, tire_stiffness)
	var mu_slope := lerpf(max_mu_slope, min_mu_slope, tire_stiffness)
	var compression := tire_rated_load / springrate
	var half_flat := 0.825 * sqrt(tire_radius*tire_radius-pow(tire_radius - compression, 2))
	var tire_patch := tire_width * 2 * half_flat
	var patch_pressure := tire_rated_load / tire_patch
	load_sens1 = mu_slope * patch_pressure + load_sens0
	
#	print_debug("Mu0 = %2.2f, Mu1 = %2.2f, Rated load = %6.2f" % [load_sens0, load_sens1, tire_rated_load])


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
