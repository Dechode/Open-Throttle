class_name TireGraph
extends Control

var normal_load := 4000.0:
	set(value):
		normal_load = value
		is_dirty = true
		_update_graph()
		

var thread_length := 0.3:
	set(value):
		thread_length = value
		tire_model.thread_length = value
		is_dirty = true
		_update_graph()

var tire_stiffness := 0.5:
	set(value):
		tire_stiffness = value
		tire_model.tire_stiffness = value
		is_dirty = true
		_update_graph()

var tire_width := 0.3:
	set(value):
		tire_width = value
		tire_model.tire_width = value
		is_dirty = true
		_update_graph()

var tire_ratio := 0.3:
	set(value):
		tire_ratio = value
		tire_model.tire_ratio = value
		is_dirty = true
		_update_graph()

var rim_size := 0.3:
	set(value):
		rim_size = value
		tire_model.tire_rim_size = value
		is_dirty = true
		_update_graph()

@export var tire_model := BaseTireModel.new():
	set(value):
		tire_model = value
		is_dirty = true
		_update_graph()

var graph_size := Vector2(600, 400)
var use_degrees := true

var is_dirty := true

@onready var long_graph: Line2D = get_node("%LongitudinalTireForceGraph")
@onready var lat_graph:  Line2D = get_node("%LateralTireForceGraph")
@onready var sat_graph:  Line2D = get_node("%SelfAligningTorqueGraph")

@onready var force_container = get_node("%ForceGraphContainer")
@onready var load_sens_container = get_node("%LoadSensGraphContainer")


func _ready() -> void:
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessValue.text = "%1.2f" % tire_model.tire_stiffness
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessSlider.value = tire_model.tire_stiffness
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireWidth/TireWidthValue.text = "%1.3f" % tire_model.tire_width
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireWidth/TireWidthSlider.value =  tire_model.tire_width
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireThreadLength/ThreadLengthSlider.value = tire_model.thread_length
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireThreadLength/ThreadLengthValue.text = "%2.2f" % tire_model.thread_length
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireRatio/TireRatioSlider.value = tire_model.tire_ratio
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireRatio/TireRatioValue.text = "%2.2f" % tire_model.tire_ratio
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/RimSize/RimSizeSlider.value = tire_model.tire_rim_size
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/RimSize/RimSizeValue.text = "%2.1f" % tire_model.tire_rim_size
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadValue.text = "%4.2f" % normal_load
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadSlider.value = normal_load
	
	_update_graph()
	force_container.connect("resized", _on_force_graph_container_resized)


func _update_graph():
	if not is_dirty:
		return
	
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
	
	var mu := 1.0
	graph_size = Vector2(DisplayServer.window_get_size().x * 0.5, DisplayServer.window_get_size().y * 0.5)
	var sample_count := 1000
	
	var force_vec := Vector3.ZERO
	for i in range(sample_count):
		var slip: float = i * 0.001
		var slip_lat = Vector2(slip, 0.0000001)
		var slip_long = Vector2(0.0000001, slip)
		
		force_vec = tire_model.update_tire_forces(slip_lat, normal_load, mu) / tire_model.load_sensitivity
		var points_lat := Vector2(slip * graph_size.x, -force_vec.x / normal_load * graph_size.y * 0.5)
		lat_graph.add_point(points_lat)
		
		var points_mz := Vector2(slip * graph_size.x, -force_vec.z / (normal_load * 0.1) * graph_size.y * 0.5)
		sat_graph.add_point(points_mz)

		force_vec = tire_model.update_tire_forces(slip_long, normal_load, mu) / tire_model.load_sensitivity
		var points_long := Vector2(slip * graph_size.x, -force_vec.y / normal_load * graph_size.y * 0.5)
		long_graph.add_point(points_long)
	
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/PeakSlipAngle.text = "Peak Slip Angle = %2.1f deg / %1.2f rad" % [rad_to_deg(tire_model.peak_sa), tire_model.peak_sa]
	_update_load_sens()
	is_dirty = false


func _update_load_sens():
	var load_sens0 = tire_model.update_load_sensitivity(0.1 * tire_model.tire_rated_load)
	var load_sens1 = tire_model.update_load_sensitivity(tire_model.tire_rated_load)
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/LoadSens0.text = "Load Sensitivity @ 10%% of rated load N = %1.2f" % load_sens0
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/LoadSens1.text = "Load Sensitivity @ Rated load = %1.2f" % load_sens1
	var curr_load_sens_txt = "Current Load Sensitivity @ %d N = %1.2f" % [int(normal_load), tire_model.update_load_sensitivity(normal_load)]
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/LoadSensCurrent.text = curr_load_sens_txt
	_draw_load_sens_graph(load_sens0, load_sens1)


func _draw_load_sens_graph(mu0, mu1):
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


func _draw_slip_numbers(degrees: bool):
	for node in $HBoxContainer/VBoxContainer/SlipNumbers.get_children():
		node.queue_free()
	
	var points := 10
	for i in range(points):
		var slip_label := Label.new()
		var minx = force_container.size.x / points
		minx -= 0.5 * slip_label.size.x
		slip_label.custom_minimum_size = Vector2(minx, 0)
		var number = i * 0.1
		if degrees:
			number = rad_to_deg(number)
		slip_label.text = "|%1.2f" % number
		$HBoxContainer/VBoxContainer/SlipNumbers.add_child(slip_label)


func _on_stiffness_slider_value_changed(value: float) -> void:
	tire_stiffness = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessValue.text = "%1.2f" % value


func _on_tire_load_slider_value_changed(value: float) -> void:
	normal_load = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadValue.text = "%4.2f" % value
	_update_graph()


func _on_tire_width_slider_value_changed(value: float) -> void:
	tire_width = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireWidth/TireWidthValue.text = "%1.3f" % value


func _on_slip_units_toggled(button_pressed: bool) -> void:
	use_degrees = not button_pressed
	_draw_slip_numbers(use_degrees)


func _on_load_sens_graph_container_resized() -> void:
	_update_load_sens()


func _on_force_graph_container_resized() -> void:
	_draw_slip_numbers(use_degrees)


func _on_thread_length_slider_value_changed(value: float) -> void:
	thread_length = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireThreadLength/ThreadLengthValue.text = "%2.2f" % value


func _on_tire_ratio_slider_value_changed(value: float) -> void:
	tire_ratio = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireRatio/TireRatioValue.text = "%2.2f" % value


func _on_rim_size_slider_value_changed(value: float) -> void:
	rim_size = value
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/RimSize/RimSizeValue.text = "%2.1f" % value
