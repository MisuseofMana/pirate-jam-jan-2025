extends Node2D

signal logo_animation_finished()
signal rack_focus()

func _on_animation_animation_finished(_anim_name):
	SceneSwitcher.switch_scene("res://scenes/game.tscn")
		
func start_rack_focus():
	rack_focus.emit()
