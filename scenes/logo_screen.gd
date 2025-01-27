extends Node2D

@onready var anims = $AnimationPlayer

func rack_in():
	anims.play("rack_zoom")
