class_name TireGraph
extends Control

enum {
	PACEJKA,
	BRUSH,
	LINEAR,
}

var normal_load := 4000.0:
	set(value):
		normal_load = value
		update_graph()
		
var mu := 1.0:
	set(value):
		mu = value
		update_graph()

var stiffness := 1.0:
	set(value):
		stiffness = value
		tire_model.tire_stiffness = value
		update_graph()

var tire_radius := 0.3:
	set(value):
		tire_radius = value
		tire_model.tire_radius = value
		update_graph()
		
var tire_width := 0.3:
	set(value):
		tire_width = value
		tire_model.tire_width = value
		update_graph()

var tire_model: BaseTireModel = PacejkaTireModel.new():
	set(value):
		tire_model = value
		update_graph()

var graph_size := Vector2(600, 400)

@onready var long_graph: Line2D = get_node("%LongitudinalTireForceGraph")
@onready var lat_graph:  Line2D = get_node("%LateralTireForceGraph")
@onready var sat_graph:  Line2D = get_node("%SelfAligningTorqueGraph")

@onready var force_container = get_node("%ForceGraphContainer")
@onready var load_sens_container = get_node("%LoadSensGraphContainer")


func _ready() -> void:
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.add_item("Pacejka")
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.add_item("Brush")
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.add_item("Linear")
	
	tire_model = PacejkaTireModel.new()
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.select(0)
	
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessValue.text = "%1.2f" % tire_model.tire_stiffness
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessSlider.value = tire_model.tire_stiffness
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireRadius/TireRadiusValue.text = "%1.2f" % tire_model.tire_radius
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireRadius/TireRadiusSlider.value = tire_model.tire_radius
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireWidth/TireWidthValue.text = "%1.3f" % tire_model.tire_width
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireWidth/TireWidthSlider.value =  tire_model.tire_width
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadValue.text = "%4.2f" % normal_load
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadSlider.value = normal_load
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/Friction/FrictionValue.text = "%1.2f" % mu
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/Friction/FrictionSlider.value = mu
	
	for i in range(1, 11):
		var slip_label = $Slip0.duplicate() as Label
		slip_label.position.x += i * DisplayServer.window_get_size().x * 0.5 / 10 - slip_label.size.x
		slip_label.text = "%1.2f" % (i * 0.1)
		add_child(slip_label)


func update_graph():
	if not lat_graph:
		push_warning("No lateral tire force graph found")
		return
	if not long_graph:
		push_warning("No longitudinal tire force graph found")
		return
	if not sat_graph:
		push_warning("No self aligning torque graph found")
		return
	
	sat_graph.clear_points()
	lat_graph.clear_points()
	long_graph.clear_points()
	
	graph_size = Vector2(DisplayServer.window_get_size().x * 0.5, DisplayServer.window_get_size().y * 0.5)
	var sample_count := 1000
	
	var force_vec_lat_sweep := Vector3.ZERO
	for i in range(sample_count):
		var slip: float = i * 0.001
		var slip_lat = Vector2(slip, 0.0000001)
		
		force_vec_lat_sweep = tire_model.update_tire_forces(slip_lat, normal_load, mu) #/ tire_model.load_sensitivity
		var points_lat := Vector2( slip * graph_size.x, -force_vec_lat_sweep.x / normal_load * graph_size.y * 0.5)
		lat_graph.add_point(points_lat, i)
	
	var force_vec_long_sweep := Vector3.ZERO
	for i in range(sample_count):
		var slip: float = i * 0.001
		var slip_vec = Vector2(0.0000001, slip)
		
		force_vec_long_sweep = tire_model.update_tire_forces(slip_vec, normal_load, mu) #/ tire_model.load_sensitivity
		var points_long := Vector2(slip * graph_size.x, -force_vec_long_sweep.y / normal_load * graph_size.y * 0.5)
		long_graph.add_point(points_long, i)
	
	var force_vec_mz := Vector3.ZERO
	for i in range(sample_count):
		var slip: float = i * 0.001
		var slip_lat = Vector2(slip, 0.0000001)
		
		force_vec_mz = tire_model.update_tire_forces(slip_lat, normal_load, mu) #/ normal_load #/ tire_model.load_sensitivity
		var points_mz := Vector2(slip * graph_size.x, -force_vec_mz.z * 0.005 * graph_size.y * 0.5)
#		var points_mz := Vector2(slip * graph_size.x, -force_vec_mz.z * 4.0 * graph_size.y * 0.5)
		sat_graph.add_point(points_mz, i)
	
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/PeakSlipAngle.text = "Peak Slip Angle = %2.2f deg" % rad_to_deg(tire_model.peak_sa)
	_update_load_sens()


func _update_load_sens():
	var load_sens0 = tire_model.update_load_sensitivity(800)
	var load_sens1 = tire_model.update_load_sensitivity(9000)
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/LoadSens0.text = "Load Sensitivity @ 800 N = %1.2f" % load_sens0
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/LoadSens1.text = "Load Sensitivity @ 9000 N = %1.2f" % load_sens1
	var curr_load_sens_txt = "Current Load Sensitivity @ %d N = %1.2f" % [int(normal_load), tire_model.update_load_sensitivity(normal_load)]
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/LoadSensCurrent.text = curr_load_sens_txt
	draw_load_sens_graph(load_sens0, load_sens1)


func draw_load_sens_graph(mu0, mu1):
	%LoadSensGraph.clear_points()
	var max_mu := 3.5
	var min_mu := 0.6
	var load_sens0_pos := Vector2.ZERO
	load_sens0_pos.y = %LoadSensGraphContainer.size.y - mu0 / max_mu * (%LoadSensGraphContainer.size.y - 30)
	load_sens0_pos.x = 10
	var load_sens1_pos: Vector2 = %LoadSensGraphContainer.size
	load_sens1_pos.x -= 10
	load_sens1_pos.y = %LoadSensGraphContainer.size.y + 30 - (min_mu / (max_mu - mu1) * %LoadSensGraphContainer.size.y)
	%LoadSensGraph.add_point(load_sens0_pos)
	%LoadSensGraph.add_point(load_sens1_pos)


func _on_stiffness_slider_value_changed(value: float) -> void:
	stiffness = value
	tire_model.tire_stiffness = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessValue.text = "%1.2f" % value


func _on_tire_load_slider_value_changed(value: float) -> void:
	normal_load = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadValue.text = "%4.2f" % value
	

func _on_friction_slider_value_changed(value: float) -> void:
	mu = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/Friction/FrictionValue.text = "%1.2f" % value
	


func _on_tire_model_option_item_selected(index: int) -> void:
	match index:
		PACEJKA:
			tire_model = PacejkaTireModel.new()
		BRUSH:
			tire_model = BrushTireModel.new()
		LINEAR:
			tire_model = LinearTireModel.new()
	tire_model.tire_stiffness = stiffness
	tire_model.tire_radius = tire_radius
	tire_model.tire_width = tire_width
	update_graph()


func _on_tire_radius_slider_value_changed(value: float) -> void:
	tire_radius = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireRadius/TireRadiusValue.text = "%1.2f" % value


func _on_tire_width_slider_value_changed(value: float) -> void:
	tire_width = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireWidth/TireWidthValue.text = "%1.3f" % value
