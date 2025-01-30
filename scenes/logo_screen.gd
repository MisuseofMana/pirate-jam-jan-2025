extends Node2D

@onready var anims = $AnimationPlayer
@onready var logo = $AnimatedLogo

func _process(_delta):
	if Input.is_action_just_pressed("swap_meep"):
		fade_to_black()

func rack_in():
	anims.play("rack_zoom")

func fade_to_black():
	anims.play("fade_in_panel")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'fade_in_panel':
		GameState.go_to_main_menu()
