class_name Treasure extends AnimatedSprite2D

func _ready() -> void:
	add_to_group("macguffin")
	frame = randi_range(0, 5)
