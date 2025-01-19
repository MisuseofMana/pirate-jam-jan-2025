extends Area2D

@onready var hurtbox = $CollisionShape2D

signal stepped_on_trap()

func _on_area_entered(_area: Area2D) -> void:
	stepped_on_trap.emit()
	call_deferred("disable_collision")
	
func disable_collision():
	hurtbox.disabled = true
