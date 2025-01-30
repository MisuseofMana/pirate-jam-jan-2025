extends Node2D

signal rack_focus()
signal fade_to_black
		
func start_rack_focus():
	rack_focus.emit()
	
func fade_in_panel():
	fade_to_black.emit()
