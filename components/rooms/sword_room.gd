class_name SwordRoom extends Room

@onready var text_anims = $Control/TextAnimations

func show_not_worthy():
	text_anims.play("unworthy")
	
func show_worthy():
	text_anims.play("worthy")
