class_name LinearTireModel
extends BaseTireModel


#func update_tire_forces(slip: Vector2, normal_load: float, surface_mu: float) -> Vector3:
#	var tire_force_vec := Vector3.ZERO
#	var stiff_vec := get_tire_stiffness()
#	var lat_stiffness := stiff_vec.x
#	var tan_stiffness := stiff_vec.y
#	var contact_patch := get_contact_patch_length()
#	var cornering_stiffness := 0.5 * lat_stiffness * (contact_patch * contact_patch)
#	var longitudinal_stiffness := 0.5 * tan_stiffness * (contact_patch * contact_patch)
#
#	var wear_mu := TIRE_WEAR_CURVE.sample_baked(tire_wear)
#	var tire_temp_scalar := tire_temperature / max_tire_temperature
#	var temp_mu := TIRE_TEMP_CURVE.sample_baked(tire_temp_scalar)
#	load_sensitivity = update_load_sensitivity(normal_load)
#	var grip := normal_load * surface_mu * wear_mu * temp_mu * load_sensitivity
#
##	print("temp mu = %f1.2f" % temp_mu)ww
#
#	peak_sa = clamp(grip / cornering_stiffness, 0.04, 1.0)
#	peak_sr = clamp(grip / longitudinal_stiffness, 0.04, 1.0)
#
#	var normalised_sa = abs(slip.x) / peak_sa
#	var normalised_sr = abs(slip.y) / peak_sr
#	var resultant_slip = sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
###
#	var sa_modified = resultant_slip * peak_sa * sign(slip.x)
#	var sr_modified = resultant_slip * peak_sr * -sign(slip.y)
#
#	tire_force_vec.x = sa_modified * cornering_stiffness
#	tire_force_vec.y = sr_modified * -longitudinal_stiffness
#
#	if resultant_slip != 0:
#		tire_force_vec.x *= abs(normalised_sa / resultant_slip)
#		tire_force_vec.y *= abs(normalised_sr / resultant_slip)
#
#	if abs(tire_force_vec).x >= grip:
#		tire_force_vec.x = grip * sign(slip.x)
#
#	if abs(tire_force_vec.y) >= grip:
#		tire_force_vec.y = grip * sign(slip.y)
#
##	tire_force_vec.x *= load_sensitivity
##	tire_force_vec.y *= load_sensitivity
#
#	var pneumatic_trail = get_pneumatic_trail(slip.x, cornering_stiffness, grip)
#	tire_force_vec.z = tire_force_vec.x * pneumatic_trail
#	return tire_force_vec


func _get_forces(normal_load: float, total_mu: float, grip: float, contact_patch := 0.0, 
				peak_slip := Vector2.ZERO, slip := Vector2.ZERO, stiff := Vector2.ZERO,
				cornering_stiff := Vector2.ZERO) -> Vector3:
	
	var normalised_sa = abs(slip.x) / peak_slip.x
	var normalised_sr = abs(slip.y) / peak_slip.y
	var resultant_slip = sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
	
	var force_vec := Vector3.ZERO
	var slip_combined := Vector2.ZERO
	
	slip_combined.x = resultant_slip * peak_sa * sign(slip.x)
	slip_combined.y = resultant_slip * peak_sr * -sign(slip.y)
	
	force_vec.x = slip_combined.x * cornering_stiff.x
	force_vec.y = slip_combined.y * -cornering_stiff.y
	
	if resultant_slip != 0:
		force_vec.x *= abs(normalised_sa / resultant_slip)
		force_vec.y *= abs(normalised_sr / resultant_slip)
	
	if abs(force_vec).x >= grip:
		force_vec.x = grip * sign(slip.x)
		
	if abs(force_vec.y) >= grip:
		force_vec.y = grip * sign(slip.y)
	
	var pneumatic_trail = get_pneumatic_trail(slip.x, cornering_stiff.x, grip)
	force_vec.z = force_vec.x * pneumatic_trail
	return force_vec
