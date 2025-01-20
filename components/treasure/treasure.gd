class_name Treasure extends Node2D

@onready var sprite = $Sprite2D

const spriteOptions : Array[CompressedTexture2D] = [
	preload("res://art/treasure/bar.png"),
	preload("res://art/treasure/coins.png"),
	preload("res://art/treasure/cup.png"),
	preload("res://art/treasure/egg.png"),
	preload("res://art/treasure/necklace.png"),
	preload("res://art/treasure/sigil.png")
]

func _ready() -> void:
	add_to_group("macguffin")
	sprite.texture = spriteOptions.pick_random()
