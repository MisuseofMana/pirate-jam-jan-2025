extends Node2D

signal logo_animation_finished()

func _on_animation_animation_finished(anim_name):
	logo_animation_finished.emit()
		
