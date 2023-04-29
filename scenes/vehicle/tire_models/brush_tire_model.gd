class_name BrushTireModel
extends BaseTireModel


func _get_forces(normal_load: float, total_mu: float, grip: float, contact_patch := 0.0, 
				peak_slip := Vector2.ZERO, slip := Vector2.ZERO, stiff := Vector2.ZERO,
				cornering_stiff := Vector2.ZERO) -> Vector3:
	
	var critical_length := 0.0
	if slip.x:
		critical_length = grip / (stiff.x * contact_patch * tan(abs(slip.x)))
	
	var force_vector := Vector3.ZERO
	
	# Self aligning moment
	if critical_length >= contact_patch: # Adhesion region
		force_vector.z = cornering_stiff.x * contact_patch * slip.x / 6
	else: # Sliding region
		if slip.x:
			var idk = (pow(grip, 2) / (12 * contact_patch * stiff.x * tan(slip.x)))
			force_vector.z = idk * (3 - ((2 * grip) / (pow(contact_patch, 2) * stiff.x * tan(slip.x))))
	
	# Tire forces
	var deflect := sqrt(pow(cornering_stiff.y * slip.y, 2) + pow(cornering_stiff.x * tan(slip.x), 2))
	if deflect == 0:
		return Vector3.ZERO

	if deflect <= 0.5 * grip * (1 - slip.y):
		force_vector.y = cornering_stiff.y * slip.y / (1 - slip.y)
		force_vector.x = cornering_stiff.x * tan(slip.x) / (1 - slip.y)
	else:
		var brushy = (1 - grip * (1 - slip.y) / (4 * deflect)) / deflect
		force_vector.y = grip * cornering_stiff.y * slip.y * brushy
		force_vector.x = grip * cornering_stiff.x * tan(slip.x) * brushy
	return force_vector
