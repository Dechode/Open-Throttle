extends Control

var current_menu = -1

@onready var play_button = $"%PlayButton"
@onready var options_button = $"%OptionsButton"
@onready var credits_button = $"%CreditsButton"
@onready var quit_button = $"%QuitButton"

@onready var credits_label = $"%CreditsLabel"
@onready var options_tab = $"%Options"
@onready var play_menu = $HBoxContainer/PlayMenu
@onready var menus := [play_menu, options_tab, credits_label]


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:


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


