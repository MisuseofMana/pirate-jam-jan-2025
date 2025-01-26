class_name EventDrawSword extends Control

@onready var text_anims: AnimationPlayer = $TextAnimations

func show_not_worthy():
	text_anims.play("unworthy")
	
func show_worthy():
	text_anims.play("worthy")

func _on_text_animations_animation_finished(anim_name):
	if anim_name == "worthy":
		
		get_parent().queue_free()
	if anim_name == "unworthy":
		GameState.notify_meep_exploded()
		get_parent().queue_free()
		
