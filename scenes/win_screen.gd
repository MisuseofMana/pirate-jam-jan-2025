class_name WinScreen extends Control

@export var sword_names : Array[String] = []
@onready var sword_name = $MarginContainer/VBoxContainer/SwordName

# Called when the node enters the scene tree for the first time.
func _ready():
	sword_name.text = sword_names.pick_random()

func _start_game():
	GameState.start_game()

func _how_to_play():
	GameState.go_to_how_to_play()
