class_name PacejkaTireModel
extends BaseTireModel


func pacejka(slip, B, C, D, E, normal_load):
	return normal_load * D * sin(C * atan(B * slip - E * (B * slip - atan(B * slip))))


func update_tire_forces(slip: Vector2, normal_load: float, surface_mu: float):
	var wear_mu = TIRE_WEAR_CURVE.sample_baked(tire_wear)
	load_sensitivity = update_load_sensitivity(normal_load)
	var mu = surface_mu * load_sensitivity * wear_mu
	
	var b = 2 + tire_stiffness * 18
	peak_sa = 0.1 + (1 - tire_stiffness) * 0.5
	peak_sr = 0.65 * peak_sa
	var normalised_sr = abs(slip.y) / peak_sr
	var normalised_sa = abs(slip.x) / peak_sa
	var resultant_slip = sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
#
	var sr_modified = resultant_slip * peak_sr * sign(slip.x) 
	var sa_modified = resultant_slip * peak_sa * sign(slip.y)
	
	var force_vec := Vector3.ZERO
	force_vec.x = pacejka(abs(sa_modified), b, 1.35, mu, 0, normal_load) * sign(slip.x)
	force_vec.y = pacejka(abs(sr_modified), b, 1.6, mu, 0, normal_load) * sign(slip.y)
	
	if resultant_slip != 0:
		force_vec.x = force_vec.x * abs(normalised_sa / resultant_slip)
		force_vec.y = force_vec.y * abs(normalised_sr / resultant_slip)
	
	var pneumatic_trail = 0.03 - normalised_sa * 0.03
	force_vec.z = force_vec.x * pneumatic_trail
	return force_vec
