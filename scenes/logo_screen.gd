extends Node2D

@onready var anims = $AnimationPlayer
@onready var logo = $AnimatedLogo

func rack_in():
	logo.logo_animation_finished.connect(_on_logo_animation_finished)
	anims.play("rack_zoom")

func _on_logo_animation_finished() -> void:
	GameState.start_game()