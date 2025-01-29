extends Node2D

signal logo_animation_finished()
signal rack_focus()

func _on_animation_animation_finished(_anim_name):
	logo_animation_finished.emit()
		
func start_rack_focus():
	rack_focus.emit()
