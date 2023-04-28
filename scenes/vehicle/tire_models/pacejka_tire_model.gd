class_name PacejkaTireModel
extends BaseTireModel


func pacejka(slip, B, C, D, E, normal_load):
	return normal_load * D * sin(C * atan(B * slip - E * (B * slip - atan(B * slip))))


func update_tire_forces(slip: Vector2, normal_load: float, surface_mu: float):
	var stiff_vec := get_tire_stiffness()
	var contact_patch := get_contact_patch_length()
	var cornering_stiffness := 0.5 * stiff_vec.x * (contact_patch * contact_patch)
	var longitudinal_stiffness := 0.5 * stiff_vec.y * (contact_patch * contact_patch)
	
	var wear_mu := TIRE_WEAR_CURVE.sample_baked(tire_wear)
	load_sensitivity = update_load_sensitivity(normal_load)
	var mu := surface_mu * wear_mu
	var grip := normal_load * mu
	
	peak_sa = clamp(grip / cornering_stiffness, 0.04, 1.0)
	peak_sr = clamp(grip / longitudinal_stiffness, 0.01, 1.0)
	
	var c_lat  := 1.10 + tire_stiffness * 0.40
	var c_long := 1.25 + tire_stiffness * 0.45
	
	var normalised_sr: float = abs(slip.y) / peak_sr
	var normalised_sa: float = abs(slip.x) / peak_sa
	var resultant_slip := sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
#
	var sr_modified: float = resultant_slip * peak_sr * sign(slip.x) 
	var sa_modified: float = resultant_slip * peak_sa * sign(slip.y)
	
	var bla := 1 - peak_sa / 0.5
	var blo := 1 - peak_sr / 0.5
	var b_lat: float = 4 + bla * 16
	var b_long: float = 4 + blo * 16
	
	var force_vec := Vector3.ZERO
	force_vec.x = pacejka(abs(sa_modified), b_lat, c_lat, mu, 0, normal_load) * sign(slip.x)
	force_vec.y = pacejka(abs(sr_modified), b_long, c_long, mu, 0, normal_load) * sign(slip.y)
	force_vec.x *= load_sensitivity
	force_vec.y *= load_sensitivity
	
	if resultant_slip != 0:
		force_vec.x = force_vec.x * abs(normalised_sa / resultant_slip)
		force_vec.y = force_vec.y * abs(normalised_sr / resultant_slip)
	
	var pneumatic_trail := get_pneumatic_trail(slip.x, cornering_stiffness, grip)
	force_vec.z = force_vec.x * pneumatic_trail
	return force_vec
