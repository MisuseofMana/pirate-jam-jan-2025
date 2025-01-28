class_name TreasureController extends Node2D

@onready var reset_clock = $ResetClock
@onready var timer = $Timer
@export var treasure_cooldown : int = 15
@onready var treasure_icon = $TreasureIcon
@onready var gpu_particles_2d = $GPUParticles2D

const TREASURE_ICON = preload("res://components/treasure/treasure_base.tscn")

func _ready() -> void:
	reset_clock.hide()
	treasure_icon.frames = randi_range(0, 5)

func _on_treasure_tree_exited():
	reset_clock.value = 100
	reset_clock.show()
	timer.start(treasure_cooldown)
	gpu_particles_2d.emitting = true
	get_tree().create_tween().tween_property(reset_clock, "value", 0, treasure_cooldown)

func treasure_restock():
	gpu_particles_2d.emitting = false
	reset_clock.hide()
	var treasureNode = TREASURE_ICON.instantiate()
	treasureNode.add_to_group("macguffin")
	add_child(treasureNode)
