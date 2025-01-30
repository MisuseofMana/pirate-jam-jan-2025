class_name Treasure extends Node2D

@onready var reset_clock = $ResetClock
@onready var timer = $Timer
@export var treasure_cooldown : int = 30
@onready var treasure_icon = $TreasureIcon
@onready var gpu_particles_2d = $GPUParticles2D

const TREASURE_ICON = preload("res://components/treasure/treasure_icon.tscn")

func _ready() -> void:
	add_to_group("macguffin")
	reset_clock.hide()

func remove_treasure_from_group():
	remove_from_group("macguffin")
	treasure_icon.hide()
	start_reset_clock()

func treasure_restock():
	gpu_particles_2d.emitting = false
	reset_clock.hide()
	treasure_icon.set_new_icon()
	treasure_icon.show()
	add_to_group("macguffin")

func start_reset_clock() -> void:
	reset_clock.value = 100
	reset_clock.show()
	timer.start(treasure_cooldown)
	gpu_particles_2d.emitting = true
	get_tree().create_tween().tween_property(reset_clock, "value", 0, treasure_cooldown)
