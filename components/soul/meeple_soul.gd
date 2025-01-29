extends Node2D
class_name MeepleSoul

@onready var soul_sprite: AnimatedSprite2D = $SoulSprite
@onready var thought: Sprite2D = $Thought
@onready var timer = $Timer

# set wait time of this timer to determine how long a soul survives in the dungeon
@onready var lifetime_timer = $LifetimeTimer
@export var soul_lifetime: int = 15

@onready var chime = $Chime
@onready var summon = $Summon

@export_range(1, 99) var soul_value: int = 1
@export var movement_speed: float = 60.0

@export var nav_agent: NavigationAgent2D
@onready var increment_label = $IncrementLabel

var movement_delta: float

var agent_map_is_empty_or_unsynced: bool:
	get(): return NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0

func _ready():
	lifetime_timer.start(soul_lifetime)
	summon.play()
	thought.hide()
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_reached.connect(_on_target_reached)

func _on_animated_sprite_2d_animation_finished():
	if soul_sprite.animation == "default":
		soul_sprite.play("move")
		go_to_sword()
	if soul_sprite.animation == "disentigrate":
		queue_free()

func _physics_process(delta: float) -> void:
	if agent_map_is_empty_or_unsynced:
		return
	if nav_agent.is_navigation_finished():
		return

	movement_delta = movement_speed * delta
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_target_reached() -> void:
	await animate_soul_value_to_parchment()
	GameState.notify_soul_collected(self)
	timer.start()
	chime.play()
	thought.show()

func animate_soul_value_to_parchment():
	increment_label.modulate = Color(0, 0, 0, 0)
	increment_label.text = '+' + str(soul_value)
	increment_label.show()
	get_tree().create_tween().tween_property(increment_label, "modulate", Color(1, 1, 1, 1), 0.3)
	get_tree().create_tween().tween_property(increment_label, "position", Vector2(-20, -40), 1)
	await get_tree().create_timer(1).timeout
	get_tree().create_tween().tween_property(increment_label, "global_position", Vector2(0, -180), 0.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().create_tween().tween_property(increment_label, "modulate", Color(0, 0, 0, 0), 0.3)
	
func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

func go_to_sword():
	var sword := get_tree().get_first_node_in_group("sword")
	if sword:
		nav_agent.target_position = sword.global_position
	
func _on_timer_timeout():
	thought.hide()
	soul_sprite.play("disentigrate")
	increment_label.hide()
	
func _soul_lifetime_ran_out():
	soul_sprite.play("disentigrate")
