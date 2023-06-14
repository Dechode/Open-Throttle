extends Control

const car_setup_menu = preload("res://scenes/gui/menus/car_setup_menu.tscn")

var current_menu = -1

@onready var play_button = $"%PlayButton"
@onready var options_button = $"%OptionsButton"
@onready var credits_button = $"%CreditsButton"
@onready var quit_button = $"%QuitButton"

@onready var credits_label = $"%Credits"
@onready var options_tab = $"%Options"
@onready var play_menu = $HBoxContainer/PlayMenu
@onready var menus := [play_menu, options_tab, credits_label]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_session_info()
	$HBoxContainer/PlayMenu/Start/HBoxContainer/Buttons/TimeMultiplier/TimeMultiplier.value = SessionManager.time_multiplier


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func toggle_current_menu(idx):
	if idx == current_menu:
		menus[idx].visible = not menus[idx].visible
		return
	for menu in menus:
		menu.hide()
	menus[idx].show()
	current_menu = idx


func _on_QuitPopUp_confirmed() -> void:
	get_tree().quit()


func _on_QuitButton_pressed() -> void:
	$QuitPopUp.show()


func _on_CreditsButton_pressed() -> void:
	toggle_current_menu(2)
	

func _on_OptionsButton_pressed() -> void:
	toggle_current_menu(1)


func _on_PlayButton_pressed() -> void:
	toggle_current_menu(0)


func _on_car_setup_button_pressed() -> void:
	$CarSetupMenu.show()
	$HBoxContainer.hide()


func _on_car_setup_back_button_pressed() -> void:
	$HBoxContainer.show()
	$CarSetupMenu.hide()


func update_session_info():
	var track = "Track: %s \n" % SessionManager.track_path
	var car = "Car: %s \n" % SessionManager.player_car_path
	var time = "Time: %2.2f \n" % SessionManager.time_of_day
	var time_mul = "Time Multiplier: %d" % SessionManager.time_multiplier
	var info_text = track + car + time + time_mul
	$HBoxContainer/PlayMenu/Start/HBoxContainer/SessionInfo/InfoLabel.text = info_text


func _on_time_of_day_slider_value_changed(value: float) -> void:
	SessionManager.time_of_day = value
	$HBoxContainer/PlayMenu/Start/HBoxContainer/Buttons/TimeOfDay/Label2.text = str(value)
	update_session_info()
	


func _on_time_multiplier_value_changed(value: float) -> void:
	SessionManager.time_multiplier = value
	update_session_info()
