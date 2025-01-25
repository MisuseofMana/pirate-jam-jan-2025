extends Area2D
class_name DamageArea

signal trap_triggered()

var trap_sprung : bool = false
@onready var coll: CollisionShape2D = $CollisionShape2D

func _on_area_entered(_area: Area2D) -> void:
	trap_triggered.emit()
	call_deferred("disable_collision")

func enable_collision():
	trap_sprung = false
	coll.disabled = false

func disable_collision():
	trap_sprung = true
	coll.disabled = true
