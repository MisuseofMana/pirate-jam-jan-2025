class_name HowToPlay extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _start_game():
	GameState.start_game()

func _slide_forward():
	animation_player.play("slide")
	
func _slide_back():
	animation_player.play_backwards("slide")
