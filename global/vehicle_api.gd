extends Node

var tire := {
	"tire_wear" : 0.0,
} 

var tires := [tire.duplicate(), tire.duplicate(), tire.duplicate(), tire.duplicate()]
var speed_kmh = 0
var selected_gear := 0


func _ready():
	pass
