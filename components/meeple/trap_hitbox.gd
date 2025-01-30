extends Area2D

@onready var hurtbox = $CollisionShape2D

signal stepped_on_trap()

func _on_area_entered(_area: Area2D) -> void:
	stepped_on_trap.emit()
	disable_collision.call_deferred()
	await get_tree().create_timer(3.5).timeout
	enable_collision.call_deferred()
	
func disable_collision():
	hurtbox.disabled = true
	
func enable_collision():
	hurtbox.disabled = false
	
