extends Area2D

signal stepped_on_trap()

func _on_area_entered(_area: Area2D) -> void:
	stepped_on_trap.emit()
