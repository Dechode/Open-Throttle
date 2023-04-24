class_name TireGraph
extends Control

enum {
	PACEJKA,
	BRUSH,
	LINEAR,
}

@export var tire_model: BaseTireModel = PacejkaTireModel.new():
	set(value):
		tire_model = value
		update_graph()
		
@export var normal_load := 4000.0:
	set(value):
		normal_load = value
		update_graph()
		
@export var mu := 1.0:
	set(value):
		mu = value
		update_graph()

@export var stiffness := 1.0:
	set(value):
		stiffness = value
		tire_model.tire_stiffness = value
		update_graph()

var graph_size := Vector2(600, 400)

@onready var long_graph: Line2D = $HBoxContainer/VBoxContainer/GraphPanel/VBoxContainer/LongitudinalTireForceGraph
@onready var lat_graph:  Line2D = $HBoxContainer/VBoxContainer/GraphPanel/VBoxContainer/LateralTireForceGraph
@onready var sat_graph:  Line2D = $HBoxContainer/VBoxContainer/GraphPanel/VBoxContainer/SelfAligningTorqueGraph


func _ready() -> void:
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.add_item("Pacejka")
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.add_item("Brush")
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.add_item("Linear")
	
	tire_model = PacejkaTireModel.new()
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireModel/TireModelOption.select(0)
	
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessValue.text = "%1.2f" % tire_model.tire_stiffness
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireStiffness/StiffnessSlider.value = tire_model.tire_stiffness
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadValue.text = "%4.2f" % normal_load
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/TireLoad/TireLoadSlider.value = normal_load
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/Friction/FrictionValue.text = "%1.2f" % mu
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer/Friction/FrictionSlider.value = mu
	
	for i in range(51):
		var slip_label = $Slip0.duplicate() as Label
		slip_label.position.x += i * DisplayServer.window_get_size().x / 51 + slip_label.size.x * 0.5 
		slip_label.text = "%1.2f" % (i * 2 * 0.01)
		add_child(slip_label)
		
	$Slip0.hide()
	
#	update_graph()


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
	
	lat_graph.clear_points()
	sat_graph.clear_points()
	long_graph.clear_points()
	
	graph_size = Vector2(DisplayServer.window_get_size().x , 400)
	var sample_count := 1000
	
	var force_vec_lat_sweep := Vector3.ZERO
	for i in range(sample_count):
		var slip: float = i * 0.001
		var slip_lat = Vector2(slip, 0.0000001)
		
		force_vec_lat_sweep = tire_model.update_tire_forces(slip_lat, normal_load, mu)
		var points_lat := Vector2( slip * graph_size.x, -force_vec_lat_sweep.x / normal_load * graph_size.y * 0.5)
		lat_graph.add_point(points_lat, i)
	
	var force_vec_long_sweep := Vector3.ZERO
	for i in range(sample_count):
		var slip: float = i * 0.001
		var slip_vec = Vector2(0.0000001, slip)
		
		force_vec_long_sweep = tire_model.update_tire_forces(slip_vec, normal_load, mu)
		var points_long := Vector2(slip * graph_size.x, -force_vec_long_sweep.y / normal_load * graph_size.y * 0.5)
		long_graph.add_point(points_long, i)
	
	var force_vec_mz := Vector3.ZERO
	for i in range(sample_count):
		var slip: float = i * 0.001
		var slip_lat = Vector2(slip, 0.0000001)
		
		force_vec_mz = tire_model.update_tire_forces(slip_lat, normal_load, mu)
		var points_mz := Vector2(slip * graph_size.x, -force_vec_mz.z / 200 * graph_size.y * 0.5)
		sat_graph.add_point(points_mz, i)
	
	$HBoxContainer/VBoxContainer/Parameters/VBoxContainer2/PeakSlipAngle/PeakSlipAngleLabel.text = "Peak Slip Angle = %2.2f deg" % rad_to_deg(tire_model.peak_sa)


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
	stiffness = stiffness

