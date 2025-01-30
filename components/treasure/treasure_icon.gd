class_name TreasureIcon extends AnimatedSprite2D

func _ready():
	set_new_icon()

func set_new_icon():
	frame = randi_range(0, sprite_frames.get_frame_count("default") - 1)
