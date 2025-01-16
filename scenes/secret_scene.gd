extends Control

@onready var gotem = $AudioStreamPlayer2D

func _ready():
	gotem.play()

func _on_button_pressed():
	SceneSwitcher.switch_scene("res://scenes/start_screen.tscn")
