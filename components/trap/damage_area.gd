extends Area2D

signal trap_triggered()

@onready var coll: CollisionShape2D = $CollisionShape2D

func _on_area_entered(area: Area2D) -> void:
	trap_triggered.emit()
	coll.disabled = true

func enable_collision():
	coll.disabled = false
