class_name PacejkaTireModel
extends BaseTireModel


func pacejka(slip, B, C, D, E, normal_load):
	return normal_load * D * sin(C * atan(B * slip - E * (B * slip - atan(B * slip))))


func _get_forces(normal_load: float, total_mu: float, grip: float, _contact_patch := 0.0, 
				slip := Vector2.ZERO, _stiff := Vector2.ZERO,
				cornering_stiff := Vector2.ZERO) -> Vector3:
	
	var c_lat  := 0.7 + tire_stiffness * 0.50
	var c_long := 1.0 + tire_stiffness * 0.65
	
	var normalised_sa: float = abs(slip.x) / peak_sa
	var normalised_sr: float = abs(slip.y) / peak_sr
	var resultant_slip := sqrt(pow(normalised_sr, 2) + pow(normalised_sa, 2))
#
	var sa_modified: float = resultant_slip * peak_sa * sign(slip.x)
	var sr_modified: float = resultant_slip * peak_sr * sign(slip.y) 
	
	var bla := 1 - peak_sa #/ 0.5
	var blo := 1 - peak_sr
	var b_lat: float = 2 + bla * 18
	var b_long: float = 2 + blo * 18
	
	var force_vec := Vector3.ZERO
	force_vec.x = pacejka(abs(sa_modified), b_lat, c_lat, total_mu, 0, normal_load) * sign(slip.x) * load_sensitivity
	force_vec.y = pacejka(abs(sr_modified), b_long, c_long, total_mu, 0, normal_load) * sign(slip.y) * load_sensitivity
	
	if resultant_slip != 0:
		force_vec.x = force_vec.x * abs(normalised_sa / resultant_slip)
		force_vec.y = force_vec.y * abs(normalised_sr / resultant_slip)
	
	var pneumatic_trail := get_pneumatic_trail(slip.x, cornering_stiff.x, grip)
	force_vec.z = force_vec.x * pneumatic_trail
	return force_vec
