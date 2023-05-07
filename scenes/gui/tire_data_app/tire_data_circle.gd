extends Control

enum tire_pos {FL,FR,RL,RR}

@export var tire_index: tire_pos = tire_pos.FL

var radius_grip_ring: float = 0
var tire_slip_max_abs: float = 0
var max_scale_n: float = 0

var tire: RaycastSuspension

func _ready():
	#set tire based on tire_index variable
	if tire_index == tire_pos.FL:
		tire = VehicleAPI.car.wheel_fl as RaycastSuspension
	if tire_index == tire_pos.FR:
		tire = VehicleAPI.car.wheel_fr as RaycastSuspension
	if tire_index == tire_pos.RL:
		tire = VehicleAPI.car.wheel_bl as RaycastSuspension
	if tire_index == tire_pos.RR:
		tire = VehicleAPI.car.wheel_br as RaycastSuspension
		
	#calculate how much newton equals to max radius (radius can be bigger)
	max_scale_n = VehicleAPI.car.mass * 9.8


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tire != null:
		#clamp absolute slip from 0 to 1 to use in lerp function, take the bigger slip from slip_vec x/y
		tire_slip_max_abs = max(clamp(abs(tire.slip_vec.x), 0.0, 1.0), clamp(abs(tire.slip_vec.y), 0.0, 1.0))
		
		#calculate the radius of the indicator based on tire load
		var grip_scale = clamp((1.0/max_scale_n) * tire.y_force, 0.0, 1.0)
		radius_grip_ring = 75 * grip_scale
	# call draw function
	queue_redraw()

func _draw():
	var center = Vector2(75, 75)
	var angle_from = 0
	var angle_to = 365
	var colorR = Color(1.0, 0.0, 0.0)#Red
	var colorG = Color(0.0, 1.0, 0.0)#Green
	
	# mix colors based on slip, green = tire has grip, red = tire has no grip
	var color_mixed = colorG.lerp(colorR, tire_slip_max_abs)
	
	# draw the circle sized based on actual load on tire
	draw_circle_arc(center, radius_grip_ring, angle_from, angle_to, color_mixed)
	
	# draw the line indicates lateral forces in newton
	var origin_x_force = center
	var target_x_force = origin_x_force + ((Vector2(61, 0) * (1.0/max_scale_n) * tire.force_vec.x)).rotated(-tire.rotation.y)
	draw_line(origin_x_force, target_x_force, Color.DARK_RED, 1, true)
	
	# draw the line indicates longitudinal forces in newton
	var origin_z_force = center
	var target_z_force = origin_z_force + ((Vector2(0, 61) * (1.0/max_scale_n) * tire.force_vec.y)).rotated(-tire.rotation.y)
	draw_line(origin_z_force, target_z_force, Color.DARK_BLUE, 1, true)
	
	var origin_damp_speed_indicator = Vector2(3, 75)
	var target_damp_speed_indicator_lo = origin_damp_speed_indicator - Vector2(0,25)
	var target_damp_speed_indicator_hi = origin_damp_speed_indicator - Vector2(0,75)

	if abs(tire.spring_speed_mm_per_seconds) <= tire.high_speed_damping_treshold:
		draw_line(origin_damp_speed_indicator, target_damp_speed_indicator_lo, Color.DARK_GREEN, 6)
	else :
		draw_line(origin_damp_speed_indicator, target_damp_speed_indicator_hi, Color.DARK_RED, 6)

#code from examples in godot docs
func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 1, true)
