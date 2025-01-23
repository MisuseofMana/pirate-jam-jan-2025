class_name Furniture extends AnimatedSprite2D

func _ready() -> void:
	add_to_group("furniture")
	frame = randi_range(0, 2)
