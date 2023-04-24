class_name LinearTireModel
extends BaseTireModel


func update_tire_forces(slip: Vector2, normal_load: float, surface_mu: float) -> Vector3:
	var tire_force_vec := Vector3.ZERO
	var cornering_stiffness := (400 + tire_stiffness * 300) * 57.2957795 # N / rad
	var longitudinal_stiffness := (500 + tire_stiffness * 300) * 57.2957795 # N / rad
	
#	var cornering_stiffness = clamp(0.165 * normal_load * 57.29577950, 100.0, 200000.0)
#	var longitudinal_stiffness = clamp(0.17 * normal_load * 57.29577950, 100.0, 200000.0)
	
	load_sensitivity = update_load_sensitivity(normal_load)
	var grip := normal_load * load_sensitivity * surface_mu
#	var grip := normal_load * surface_mu
	
	peak_sa = clamp(grip / cornering_stiffness, 0.0001, 1.0)
	peak_sr = clamp(grip / longitudinal_stiffness, 0.0001, 1.0)
#	peak_sr = 0.65 * peak_sa
	
	var normalised_sa = abs(slip.x) / peak_sa
	var normalised_sr = abs(slip.y) / peak_sr
	var resultant_slip = sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
##
	var sa_modified = resultant_slip * peak_sa * sign(slip.x)
	var sr_modified = resultant_slip * peak_sr * sign(slip.y)
	
	tire_force_vec.x = sa_modified * cornering_stiffness
	tire_force_vec.y = sr_modified * -longitudinal_stiffness
	
	if resultant_slip != 0:
		tire_force_vec.x *= abs(normalised_sa / resultant_slip)
		tire_force_vec.y *= abs(normalised_sr / resultant_slip)
		tire_force_vec.z *= abs(normalised_sa / resultant_slip)
	
	if abs(tire_force_vec).x >= grip:
		tire_force_vec.x = grip * sign(slip.x)
		
	if abs(tire_force_vec.y) >= grip:
		tire_force_vec.y = grip * sign(slip.y)
	
	
#	print(rad_to_deg(peak_sa))
	print(tire_force_vec.x / normal_load)
	return tire_force_vec
