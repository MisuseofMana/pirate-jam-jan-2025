class_name Meeple extends Node2D

#@export var stats : MeepleStats
@onready var thought : Sprite2D = $Thought
@onready var thought_timer = $ThoughtTimer
@onready var anims = $AnimationPlayer
@onready var hurtbox = $TrapHitbox/CollisionShape2D
@onready var sprite = $Meeple

@export_group("Visuals")
@export_enum("looter", "priest") var meeple_skin: String = 'looter'
@export_group("Stats")
@export_range(1, 4) var health: int
@export_range(0, 1, 0.1) var greed: float
@export_range(0, 1, 0.1) var piety: float
@export var movement_speed: float = 20.0

@export_group("AI")
@export var macguffin_strategy: MacguffinStrategy

@export_group("Internal")
@export var nav_agent: NavigationAgent2D

const MEEPLE_SOUL = preload("res://components/meeple/meeple_soul.tscn")

const THOUGHT_HEART_EMPTY = preload("res://art/meeple/thought-heart-empty.png")
const THOUGHT_HEART_QUARTER = preload("res://art/meeple/thought-heart-quarter.png")
const THOUGHT_HEART_HALF = preload("res://art/meeple/thought-heart-half.png")
const THOUGHT_HEART_THREEQUARTER = preload("res://art/meeple/thought-heart-threequarter.png")
const THOUGHT_HEART_FULL = preload("res://art/meeple/thought-heart-full.png")

signal die(whoDied)

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
	sprite.animation = meeple_skin
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
	thought.show()
	
	var thought_hearts_array : Array[CompressedTexture2D] = [
		THOUGHT_HEART_EMPTY,
		THOUGHT_HEART_QUARTER,
		THOUGHT_HEART_HALF,
		THOUGHT_HEART_THREEQUARTER,
		THOUGHT_HEART_FULL,
	]
	var oldHealth : int = health
	health -= 1
	
	thought.texture = thought_hearts_array[oldHealth]
	thought.show()
	thought_timer.wait_time = 0.1
	
#	animate the damage indicator as a thought bubble
	for i in 2:
		thought_timer.start()
		await thought_timer.timeout
		thought.texture = thought_hearts_array[health]
		thought_timer.start()
		await thought_timer.timeout
		thought.texture = thought_hearts_array[oldHealth]
	
	thought.texture = thought_hearts_array[health]
	thought_timer.wait_time = 0.3
	thought_timer.start()
	await thought_timer.timeout
	thought.hide()
	
	if (health <= 0):
		anims.play('die')
	
	thought_timer.wait_time = 0.8
	thought_timer.start()
	await thought_timer.timeout
	hurtbox.disabled = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'die':
		die.emit(self)
#		spawn soul in scene, give it values, send it to 
		var soul = MEEPLE_SOUL.instantiate()
		soul.global_position = global_position
		get_tree().get_root().get_child(-1).add_child(soul)
		queue_free()
