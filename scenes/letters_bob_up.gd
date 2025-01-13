extends AudioStreamPlayer2D

@onready var text = $"../Text"

const SPEED = 0.2

func _ready():
	animate_letters()

func animate_letters():
	for letter in text.get_children():
		create_tween().tween_property(letter, "offset", Vector2(0, -2), SPEED)
		
