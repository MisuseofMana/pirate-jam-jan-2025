extends Control

@export var sword_names : Array[String] = []
@onready var sword_name = $MarginContainer/VBoxContainer/SwordName

# Called when the node enters the scene tree for the first time.
func _ready():
	sword_name.text = sword_names.pick_random()

func _on_button_pressed():
	GameState.start_game()
