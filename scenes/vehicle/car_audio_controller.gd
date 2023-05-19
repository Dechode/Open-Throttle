extends Node

@export var stream_engine_main_on: AudioStream
@export var stream_engine_main_off: AudioStream
@export var stream_plop: AudioStream
@export var stream_drag_wind: AudioStream
@export var stream_brakes: AudioStream
@export var stream_gear_change: AudioStream

@export_group("Engine")

@export var db_blend_curve_on:Curve = Curve.new()
@export var db_blend_curve_off:Curve = Curve.new()
@export_range(-80.0, 0, 0.1) var db_engine_on := -20.0#db of the on throttle file
@export_range(-80.0, 0, 0.1) var db_engine_off := -20.0#db of the off throttle file
@export var db_rpm_curve:Curve = Curve.new()#db curve to influence db per rpm(to rise db on low rpm)
@export var recorded_rpm_on := 1000 #rpm on which on_throttle sample is recorded
@export var recorded_rpm_off := 1000 #rpm on which off_throttle sample is recorded
@export_range(1, 10, 1) var rpm_interpolation_frames := 5.0#frames to interpolate sound because of rpm spikes
@export_range(0.0, 10.0, 0.1) var idle_noise_speed := 3.0#how fast the engine fluctuates rpm in idle
@export_range(0.0, 0.5, 0.01) var idle_noise_octave := 0.5#how much the engine fluctuates rpm in idle (+/- in absolute pitch scale)
@export var filter_off_throttle = false
@export var filter_on_throttle = false
@export_range(0.0, 1000.0, 0.1) var high_pass_cutoff_freq := 0#influence off gas sound per high_pass_filter (0 is no effect,)
@export_range(10, 22500, 0.1) var low_pass_cutoff_freq := 22500#influence off gas sound per low_pass_filter (22500 is no effect,)

@export_group("Exhaust")
@export_range(-80.0, 0, 0.1) var db_plopping := -20.0#loudness of exhaust plopping
@export_range(1.0, 100.0, 0.1) var plopping_frequence := 15.0#
@export_range(-1.0, 1.0, 0.1) var plopping_probability := 0.7# higher value is more plopping
@export_range(0.0, 10.0, 0.1) var plopping_time := 1.5# how long exhaust is plopping after release throttle
@export_range(0.0, 1.0, 0.01) var plopping_rpm_treshold := 0.6#just plopping when release throttle above normalized rpm (set to 0 to plopping on any rpms)

@export_group("Brakes")
@export_range(-80.0, 0, 0.1) var db_brake_noise := -20.0#loudness of brake noise
@export_range(0.0, 10.0, 0.1) var brake_noise_time_offset := 1.0#timeoffset to play noise
@export_range(0.0, 1.0, 0.05) var brake_noise_brake_force := 0.5#only play above normalized brake power
@export_range(1.0, 5.0, 0.1) var brake_noise_fade_in_time := 1.0#time to fade in brake noise
@export_range(0.2, 1.0, 0.1) var brake_noise_pitch := 1.0#pitch scale of brake noise

var idle_rpm := 700.0
var rev_limit_rpm := 7000.0

var pitch_scale_factor := 0.001
var pitch_min := 0.0
var pitch_max := 0.0

var time := 0.0
var timer_plopp := 0.0
var timer_brakes := 0.0

var prev_gear := 0

var noise = FastNoiseLite.new()

var turbo_pressure := 0.0

@onready var car_ref:BaseCar = $".."
@onready var car_audio_player_engine_on = $StreamEngineOn
@onready var car_audio_player_engine_off = $StreamEngineOff
@onready var car_audio_player_plop = $StreamExhaustPlop
@onready var car_audio_player_wind = $StreamDriveWind
@onready var car_audio_player_brakes = $StreamBrakes
@onready var car_audio_player_gear_change = $StreamGearChange

var high_pass_filter:AudioEffectHighPassFilter
var low_pass_filter:AudioEffectLowPassFilter

var rpms:Array[float]
var rpm_average := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.frequency = 1.0

	idle_rpm = car_ref.car_params.rpm_idle
	rev_limit_rpm = car_ref.car_params.max_engine_rpm

	pitch_min = idle_rpm * 0.001
	pitch_max = rev_limit_rpm * 0.001

	car_audio_player_engine_on.stream = stream_engine_main_on
	car_audio_player_engine_on.volume_db = -40
	car_audio_player_engine_on.play()
	
	car_audio_player_engine_off.stream = stream_engine_main_off
	car_audio_player_engine_off.volume_db = -40
	car_audio_player_engine_off.play()

	car_audio_player_plop.stream = stream_plop
	
	car_audio_player_wind.stream = stream_drag_wind
	
	car_audio_player_brakes.stream = stream_brakes
	
	car_audio_player_gear_change.stream = stream_gear_change

	car_audio_player_wind.volume_db = -50
	car_audio_player_wind.play()
	
	
	high_pass_filter = AudioServer.get_bus_effect(1, 0) as AudioEffectHighPassFilter
	low_pass_filter = AudioServer.get_bus_effect(1, 1) as AudioEffectLowPassFilter


func _process(delta):
	#calculate db of drag wind
	var car_linear_velocity_ms = car_ref.linear_velocity.length()
	car_audio_player_wind.volume_db = -50 + (car_linear_velocity_ms * 0.7)
	
	rpms.push_front(car_ref.rpm)
	if rpms.size() > rpm_interpolation_frames:
		rpms.remove_at(rpms.size() - 1)
	rpm_average = 0.0
	for rpm in rpms:
		rpm_average += rpm
	rpm_average = rpm_average / rpms.size()
	#calculate engine db based on rpm ,rpm_curve and blend it dependent on throttle pos
	var rpm_normalized = (car_ref.rpm - idle_rpm) / (rev_limit_rpm - idle_rpm)
	car_audio_player_engine_on.volume_db = (db_engine_on - 20) + clamp((20 * db_blend_curve_on.sample_baked(car_ref.throttle_input)), 0, 20) + (db_rpm_curve.sample_baked(rpm_normalized))
	car_audio_player_engine_off.volume_db = (db_engine_off - 20) + (20 * db_blend_curve_off.sample_baked(car_ref.throttle_input)) +(db_rpm_curve.sample_baked(rpm_normalized))

	# calculate pitch from car rpm
	var pitch_out = clamp(rpm_average * 0.001, pitch_min, pitch_max)
	
	if filter_off_throttle:
		high_pass_filter.cutoff_hz = clamp(20 + (db_blend_curve_off.sample_baked(car_ref.throttle_input) * (high_pass_cutoff_freq - 20)), 20 , 500)
		low_pass_filter.cutoff_hz = 20500 - (db_blend_curve_off.sample_baked(car_ref.throttle_input) * (20500 - low_pass_cutoff_freq))
	elif filter_on_throttle:
		high_pass_filter.cutoff_hz = clamp(20 + (db_blend_curve_on.sample_baked(car_ref.throttle_input) * (high_pass_cutoff_freq - 20)), 20 , 500)
		low_pass_filter.cutoff_hz = 20500 - (db_blend_curve_on.sample_baked(car_ref.throttle_input) * (20500 - low_pass_cutoff_freq))
	else :
		high_pass_filter.cutoff_hz = 20
		low_pass_filter.cutoff_hz = 20500
	print("cutoff highpass= " + str(high_pass_filter.cutoff_hz))

	#fade in and out the brake disc sample 
	if car_ref.brake_input > 0.5 and car_linear_velocity_ms > 5:
		timer_brakes += delta
		if timer_brakes > 0.1:
			if !car_audio_player_brakes.playing:
				car_audio_player_brakes.play()
			if car_audio_player_brakes.volume_db < db_brake_noise:
				car_audio_player_brakes.volume_db += delta * (50.0 / brake_noise_fade_in_time)
				car_audio_player_brakes.pitch_scale = brake_noise_pitch
	else :
		timer_brakes = 0.0
		if car_audio_player_brakes.volume_db > -50:
			car_audio_player_brakes.volume_db -= delta * 50

	#play gear change sample when gear-change is detected
	if prev_gear != car_ref.drivetrain.selected_gear:
		turbo_pressure = 0.0
		car_audio_player_gear_change.play()
		if prev_gear > car_ref.drivetrain.selected_gear:#if down shift, plopp again
			timer_plopp = 0.0
		prev_gear = car_ref.drivetrain.selected_gear

	#reset plopping timer when throttle > 0.05 to plopp again when release
	if car_ref.throttle_input > 0.05:
		timer_plopp = 0

	#add rpm fluctuations when idle
	if pitch_out < pitch_min * 1.05:
		pitch_out += (idle_noise_octave * noise.get_noise_1d(time * idle_noise_speed))

	#play exhaust plopping's as long as timer < timeout
	if pitch_out > (pitch_max * plopping_rpm_treshold) and car_ref.throttle_input < 0.05 and timer_plopp < plopping_time:
		if noise.get_noise_1d(time * plopping_frequence) > (1 - plopping_probability):
			car_audio_player_plop.play()
			car_audio_player_plop.volume_db = randf_range(db_plopping - 6, db_plopping + 6)
			car_audio_player_plop.pitch_scale = randf_range(1.5, 4.5)

	#set pitch and add deltas to the timers
	car_audio_player_engine_on.pitch_scale = pitch_out / (recorded_rpm_on * 0.001)
	car_audio_player_engine_off.pitch_scale = pitch_out / (recorded_rpm_off * 0.001)
	timer_plopp += delta
	time += delta#used for noise request value
	
