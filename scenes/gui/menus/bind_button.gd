class_name BindButton
extends Button

@export var action: String = "ui_up"

var is_dirty: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(InputMap.has_action(action))
	set_process_unhandled_input(false)
	display_current_bind()


func _process(delta: float) -> void:
	if !is_dirty:
		display_current_bind()


func _toggled(p_pressed: bool) -> void:
	set_process_unhandled_input(p_pressed)
	if p_pressed:
		is_dirty = true
		text = "..."
		release_focus()
	else:
		is_dirty = false
		display_current_bind()


func _unhandled_input(event: InputEvent) -> void:
	remap_action(event)


func remap_action(event: InputEvent):
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) >= 0.2:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			OptionsManager.save_options()
			self.button_pressed = false
	
	elif event is InputEventJoypadButton:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		OptionsManager.save_options()
		self.button_pressed = false
		
	elif event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			print("Esc pressed")
			text = ""
			self.button_pressed = false
			return
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		OptionsManager.save_options()
		self.button_pressed = false


func display_current_bind():
	var event_list := InputMap.action_get_events(action)
	if event_list.size() > 0:
		var event_info := ""
		for event in event_list:
			if event is InputEventJoypadMotion:
				event_info += "Joy %d, Axis %d " % [event.device, event.axis]
			if event is InputEventJoypadButton:
				event_info += "Joy %d, Button %d " % [event.device, event.button_index]
			if event is InputEventKey:
				event_info += "%s Key " % event.as_text().replacen(" (physical)","")
		text = event_info
	else:
		text = "Unbinded"

