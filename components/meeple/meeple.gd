class_name Meeple extends Node2D

@onready var hearts: Node2D = $Hearts
@export var stats : MeepleStats

func _ready():
	for heart : AnimatedSprite2D in hearts.get_children():
		pass
