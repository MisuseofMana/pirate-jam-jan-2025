class_name EventDrawSword extends Control

@onready var text_anims: AnimationPlayer = $TextAnimations

signal you_lost()
signal you_survived()

func show_not_worthy():
	text_anims.play("unworthy")
	
func show_worthy():
	text_anims.play("worthy")

func _on_text_animations_animation_finished(anim_name):
	if anim_name == "worthy":
		you_lost.emit()
		print('you lose')
	if anim_name == "unworthy":
		print('explode meep and dont spawn a soul!')
		you_survived.emit()
		queue_free()
		
