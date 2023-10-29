class_name LinearTireModel
extends BaseTireModel


func _get_forces(_normal_load: float, _total_mu: float, grip: float, _contact_patch := 0.0, 
				slip := Vector2.ZERO, _stiff := Vector2.ZERO,
				cornering_stiff := Vector2.ZERO) -> Vector3:
	
	var normalised_sa: float = abs(slip.x) / peak_sa
	var normalised_sr: float = abs(slip.y) / peak_sr
	var resultant_slip := sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
	
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
	
	force_vec.x *= load_sensitivity
	force_vec.y *= load_sensitivity
	
	var pneumatic_trail = get_pneumatic_trail(slip.x, cornering_stiff.x, grip)
	force_vec.z = force_vec.x * pneumatic_trail
	return force_vec
