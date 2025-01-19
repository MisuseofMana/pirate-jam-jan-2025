class_name Meeple extends Node2D

@onready var hearts: Node2D = $Hearts

#@export var stats : MeepleStats
@onready var thought: Sprite2D = $Thought

@export_group("Stats")
@export_range(1, 4) var health: int
@export_range(1, 4) var max_health: int = 4
@export_range(0, 1, 0.1) var greed: float
@export_range(0, 1, 0.1) var piety: float
@export var movement_speed: float = 20.0

@export_group("AI")
@export var macguffin_strategy: MacguffinStrategy

@export_group("Internal")
@export var nav_agent: NavigationAgent2D

signal die(whoDied)

const BLANK_HEART = preload("res://art/meeple/blank-heart.png")

var target: Node2D:
	set(new_value):
		if new_value == target:
			return
		target = new_value
		if target:
			nav_agent.target_position = target.global_position

var movement_delta: float

func _ready() -> void:
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	thought.hide()
	for i: int in hearts.get_children().size():
		if i + 1 > max_health:
			hearts.get_child(i).queue_free()
	_select_target.call_deferred()

func _select_target() -> void:
	var macguffins: Array[Node2D] = []
	macguffins.assign(get_tree().get_nodes_in_group("macguffin"))
	target = macguffin_strategy.select_macguffin(self, macguffins)
	
func _physics_process(delta: float) -> void:
	if not target:
		_select_target()
		return

	nav_agent.target_position = target.global_position

	var is_empty_or_unsynced = NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0
	if is_empty_or_unsynced:
		return
	if nav_agent.is_navigation_finished():
		target.queue_free()
		target = null
		return

	movement_delta = movement_speed * delta
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

func take_damage():
	health -= 1
	hearts.get_child(-1).texture = BLANK_HEART
	if (health <= 0):
		die.emit(self)
		queue_free()
