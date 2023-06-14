extends Node

var options_config: OptionsConfig
var resolutions := {
	0: [Vector2i(960,720), Vector2i(1024,768), 
		Vector2i(1280,960), Vector2i(1400, 1050),
		Vector2i(1440,1080), Vector2i(1600,1200),
		Vector2i(1856,1392), Vector2i(1920,1440),
		Vector2i(2048,1536)],
	
	1: [Vector2i(1280,720), Vector2i(1600,900), 
		Vector2i(1920,1080), Vector2i(2560,1440), 
		Vector2i(3200,1800), Vector2i(3840,2160)],
	
	2: [Vector2i(1280,800), Vector2i(1920,1200), Vector2i(3840,2400)] 
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_options()
	set_resolution(options_config.config["resolution"])
	set_vsync(options_config.config["vsync"])
	
	AudioServer.set_bus_volume_db(0, linear_to_db(options_config.config["master_audio_vol"]))


func load_options():
	if !ResourceLoader.exists("user://options.tres"):
		options_config = OptionsConfig.new()
		_load_inputmap()
		save_options()
		return
	options_config = ResourceLoader.load("user://options.tres")
	if !options_config is OptionsConfig:
		options_config = OptionsConfig.new()
	if !options_config:
		push_error("Error! Cant load game options")
		return
	_load_inputmap()
	save_options()


func save_options():
	_save_inputmap()
	var error = ResourceSaver.save(options_config, "user://options.tres")
	if error != OK:
		push_error("Error saving game options")
	
	AudioServer.set_bus_volume_db(0, linear_to_db(options_config.config["master_audio_vol"]))


func _save_inputmap():
	for action in InputMap.get_actions():
		options_config.config["input_map"][action] = InputMap.action_get_events(action)


func _load_inputmap():
	for action in options_config.config["input_map"]:
		InputMap.action_erase_events(action)
		for event in options_config.config["input_map"][action]:
			InputMap.action_add_event(action, event)


func set_config_value(key, value):
	if options_config.config.has(key):
		options_config.config[key] = value
	save_options()


func get_config_value(key):
	if options_config.config.has(key):
		return options_config.config[key]
	push_error("No config value found with key %s" % str(key))
	return null


func set_fullscreen(value):
	load_options()
	set_resolution(options_config.config["resolution"])
	options_config.config["fullscreen"] = value
	var mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	save_options()


func set_resolution(index):
	index = int(index)
	load_options()
	options_config.config["resolution"] = index
	var ratio = options_config.config["aspect_ratio"]
	var res = resolutions[ratio][index]
	DisplayServer.window_set_size(res)
	save_options()


func set_vsync(value):
	load_options()
	options_config.config["vsync"] = value
	DisplayServer.window_set_vsync_mode(value)
	save_options()
