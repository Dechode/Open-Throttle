extends Panel


func _ready() -> void:
	update_credits_label()


func update_credits_label():
	var file := FileAccess.open("res://credits.txt", FileAccess.READ)
	if not file:
		push_error("No credits.txt found")
		return
	var credits_txt := file.get_as_text()
	var godot_credits := "Godot: \n"
	godot_credits += Engine.get_license_text()
	godot_credits = godot_credits.indent("	")
	credits_txt += godot_credits
	$CreditsLabel.text = credits_txt

