class_name RaycastSuspension
extends RayCast3D

############# Choose what tire formula to use #############
var tire_model: BaseTireModel 

############# Suspension stuff #############
var spring_length := 0.2
var spring_stiffness := 20000.0
var bump := 5000.0
var rebound := 3000.0
var anti_roll := 0.0

############# Tire stuff #############
var wheel_mass := 15.0
var tire_radius := 0.3
var ackermann := 0.15

var tire_wear := 0.0
var tire_temp := 20.0
var surface_mu := 1.0
var rolling_resistance := 0.0 
var rolling_resistance_coefficient := 0.02

var y_force := 0.0

var wheel_inertia := 0.0
var spin := 0.0 :
	set = set_spin, get = get_spin

var z_vel := 0.0
var local_vel := Vector3.ZERO

var force_vec := Vector3.ZERO
var slip_vec := Vector2.ZERO
var peak_slip := Vector2.ZERO
var prev_pos := Vector3.ZERO

var prev_compress := 0.0
var spring_curr_length := spring_length


@onready var car = get_parent() as BaseCar
@onready var wheelmesh = $MeshInstance3D


func _init() -> void:
	tire_model = BaseTireModel.new()


func _ready() -> void:
#	var nominal_load = car.weight * 0.25
	wheel_inertia = 0.5 * wheel_mass * pow(tire_radius, 2)
	set_target_position(Vector3.DOWN * (spring_length + tire_radius))
	peak_slip.x = 0.12
	peak_slip.y = 0.09


func _process(delta: float) -> void:
	if abs(slip_vec.x) >= peak_slip.x or abs(slip_vec.y) >= peak_slip.y:
		$TireMarks.emitting = self.is_colliding()
	else:
		$TireMarks.emitting = false


func _physics_process(delta: float) -> void:
	peak_slip.x = tire_model.peak_sa
	peak_slip.y = tire_model.peak_sr
	var larger_slip: float = max(abs(slip_vec.x), abs(slip_vec.y))
	var friction_power := force_vec.length() * local_vel.length() * larger_slip * 0.01
	
	if abs(z_vel) > 2.0:
		friction_power = force_vec.length() * local_vel.length() * larger_slip
	
	tire_wear = tire_model.update_tire_wear(tire_wear, friction_power, delta)
	tire_temp = tire_model.update_tire_temps(tire_temp, friction_power, z_vel, delta)
	
#	print(tire_temp)
	
	wheelmesh.position.y = -spring_curr_length
	wheelmesh.rotate_x(wrapf(-spin * delta,0, TAU))


func set_params(params: WheelSuspensionParameters):
	tire_model =  params.tire_model
	spring_length = params.spring_length
	spring_stiffness = params.spring_stiffness
	bump = params.bump
	rebound = params.rebound
	wheel_mass = params.wheel_mass
	tire_radius = params.tire_model.tire_radius
	ackermann = params.ackermann
	anti_roll = params.anti_roll
	
	
	wheel_inertia = 0.5 * wheel_mass * pow(tire_radius, 2)
	set_target_position(Vector3.DOWN * (spring_length + tire_radius))


func apply_forces(opposite_comp, delta):
	############# Local forward velocity #############
	local_vel = (global_transform.origin - prev_pos) / delta * global_transform.basis
	z_vel = -local_vel.z
	var planar_vect = Vector2(local_vel.x, local_vel.z).normalized()
	prev_pos = global_transform.origin
	
	var surface := ""
	############# Suspension #################
	if is_colliding():
		if get_collider().get_groups().size() > 0:
			surface = get_collider().get_groups()[0]
		surface_mu = 1.0
		if surface:
			if surface == "Tarmac":
				surface_mu = 1.0 
				rolling_resistance_coefficient = 0.01
			elif surface == "Gravel":
				surface_mu = 0.7
				rolling_resistance_coefficient = 0.025
			elif surface == "Grass":
				surface_mu = 0.6  
				rolling_resistance_coefficient = 0.03
			elif surface == "Snow":
				surface_mu = 0.4
				rolling_resistance_coefficient = 0.035
		
		spring_curr_length = get_collision_point().distance_to(global_transform.origin) - tire_radius
	else:
		rolling_resistance_coefficient = 0.0
		spring_curr_length = spring_length
	
	var compress = clamp(1 - spring_curr_length / spring_length, 0.0, 1.0)
	y_force = spring_stiffness * compress * spring_length
	
	if (compress - prev_compress) >= 0:
		y_force += (bump + wheel_mass * 9.81) * (compress - prev_compress) * spring_length / delta
	else:
		y_force += rebound * (compress - prev_compress) * spring_length  / delta
	
	y_force = max(0, y_force)
	
	prev_compress = compress
	
	# Somewhat made up speed relative rolling resistance
	rolling_resistance_coefficient *= abs(z_vel) / 27
	rolling_resistance_coefficient = clamp(rolling_resistance_coefficient, 0, 0.07)

	rolling_resistance = rolling_resistance_coefficient * y_force
	
	############### Slip #######################
	slip_vec.x = asin(clamp(-planar_vect.x, -1, 1)) # X slip is lateral slip
	slip_vec.y = 0.0 # Y slip is the longitudinal Z slip
	force_vec = Vector3.ZERO
	
	
	############### Calculate and apply the forces #######################
	if is_colliding():
		if abs(z_vel) > 0.01:
			slip_vec.y = (z_vel - spin * tire_radius) / abs(z_vel)
		else:
			if is_zero_approx(spin):
				slip_vec.y = 0.0001 * sign(z_vel)
			else:
				slip_vec.y = 0.0001 * abs(spin) * sign(z_vel) # This is to avoid "getting stuck" if local z velocity is absolute 0
	
		force_vec = tire_model.update_tire_forces(slip_vec, y_force, surface_mu)
		
		var contact = get_collision_point() - car.global_transform.origin
		var normal = get_collision_normal()
		
		car.apply_force(normal * y_force, contact)
		car.apply_force(global_transform.basis.x * force_vec.x, contact)
		car.apply_force(global_transform.basis.z * force_vec.y, contact)
		
		### Return suspension compress info for the car bodys antirollbar calculations
		if compress !=0:
			compress = 1 - (spring_curr_length / spring_length)
			y_force += anti_roll * (compress - opposite_comp)
		return compress
	else:
		### stop wheels not colliding from spinning endlessly
		spin -= sign(spin) * delta * 2 / wheel_inertia 
		return 0.0


func apply_torque(drive_torque, brake_torque, drive_inertia, delta):
#	print(drive_torque)
	var prev_spin = spin
	var net_torque = force_vec.y * tire_radius
	net_torque += drive_torque
	
	if abs(spin) < 5 and brake_torque > abs(net_torque):
		spin = 0
	else:
		net_torque -= (brake_torque + rolling_resistance) * sign(spin)
		spin += delta * net_torque / (wheel_inertia + drive_inertia)
		spin = clamp(spin, -1000, 1000)
	
	if drive_torque * delta == 0:
		return 0.5
	else:
		return (spin - prev_spin) * (wheel_inertia + drive_inertia) / (drive_torque * delta)


func steer(input, max_steer):
	rotation.y = max_steer * (input + (1 - cos(input * 0.5 * PI)) * ackermann)


func get_spin():
	return spin


func set_spin(value):
	spin = value


func get_reaction_torque():
	return force_vec.y * tire_radius
