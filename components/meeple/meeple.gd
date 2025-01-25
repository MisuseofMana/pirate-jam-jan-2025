class_name Meeple extends Node2D

signal info_changed

const MEEPLE_SOUL = preload("res://components/soul/meeple_soul.tscn")
const THOUGHT_HEART_EMPTY = preload("res://art/meeple/thought-heart-empty.png")
const THOUGHT_HEART_QUARTER = preload("res://art/meeple/thought-heart-quarter.png")
const THOUGHT_HEART_HALF = preload("res://art/meeple/thought-heart-half.png")
const THOUGHT_HEART_THREEQUARTER = preload("res://art/meeple/thought-heart-threequarter.png")
const THOUGHT_HEART_FULL = preload("res://art/meeple/thought-heart-full.png")

@export var meeple_names: Array[String] = []

@export_group("Visuals")
@export var meeple_skin: SpriteFrames = preload("res://components/meeple/meeple_looter_skin.tres")

@export_group("Stats")
@export_range(1, 4) var health: int = 4:
	set(value):
		if value == health: return
		health = value
		info_changed.emit()
@export_range(0, 1, 0.1) var greed: float = 0.1
@export_range(0, 1, 0.1) var piety: float = 0.1
@export_range(1, 99) var soul_value: int = 1
@export var movement_speed: float = 20.0
@export var treasure_collected: int = 0:
	set(value):
		if value == treasure_collected: return
		treasure_collected = value
		info_changed.emit()
@export var max_treasure: int = 3:
	set(value):
		if value == max_treasure: return
		max_treasure = value
		info_changed.emit()

@export_group("AI")
@export var macguffin_strategy: MacguffinStrategy
@export var explore_room_strategy: RoomStrategy
@export_range(0, 1, 0.01) var trap_awareness_chance: float
@export_flags_2d_navigation var nav_flags_normal: int
@export_flags_2d_navigation var nav_flags_avoid_traps: int

@export_group("Internal")
@export var nav_agent: NavigationAgent2D
@export var brain: StateChart
@export var hover_hitbox: Area2D

@onready var thought: Sprite2D = $Thought
@onready var anims = $AnimationPlayer
@onready var hurtbox = $TrapHitbox/CollisionShape2D
@onready var meeple_sprite = $Meeple

@onready var meeple_name: String = meeple_names.pick_random()

@onready var current_room: Room = get_parent()
@onready var overlapping_rooms: Array[Room] = [current_room]
@onready var visited_rooms: Array[Node2D] = [current_room]

var debug: bool = false
var movement_delta: float
var target_macguffin: Node2D = null
var agent_map_is_empty_or_unsynced: bool:
	get(): return NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0
var is_dead: bool = false

static func get_all(node_in_tree: Node) -> Array[Meeple]:
	var meeples: Array[Meeple] = []
	for child in node_in_tree.get_tree().get_nodes_in_group("meeple"):
		if child is Meeple:
			meeples.append(child)
	return meeples

func _ready() -> void:
	add_to_group("meeple")

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_reached.connect(_on_target_reached)

	meeple_sprite.sprite_frames = meeple_skin
	meeple_sprite.play("default")

	thought.hide()

	hover_hitbox.mouse_entered.connect(_on_hovered)
	hover_hitbox.mouse_exited.connect(_on_unhovered)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug_mode"):
		debug = not debug
		nav_agent.debug_enabled = debug
	
func _on_room_hitbox_entered(area: Area2D) -> void:
	if not area is Room:
		return

	if not visited_rooms.has(area):
		visited_rooms.append(area)
	
	if not overlapping_rooms.has(area):
		overlapping_rooms.append(area)
		current_room = overlapping_rooms.back()

func _on_room_hitbox_exited(area: Area2D) -> void:
	if not area is Room:
		return

	if overlapping_rooms.has(area):
		overlapping_rooms.erase(area)
		if overlapping_rooms.is_empty():
			current_room = null
		else:
			current_room = overlapping_rooms.back()

func _on_hovered() -> void:
	MeepPeeper.notify_meeple_hovered(self)

func _on_unhovered() -> void:
	MeepPeeper.notify_meeple_unhovered(self)
			
func _get_known_macguffins() -> Array[Node2D]:
	var macguffins: Array[Node2D] = []
	for macguffin in get_tree().get_nodes_in_group("macguffin"):
		if macguffin.get_parent() == current_room:
			macguffins.append(macguffin)
	return macguffins

func _get_other_known_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	for room in get_tree().get_nodes_in_group("room"):
		if room != current_room and room is Room:
			rooms.append(room)
	return rooms
	
func _physics_process(delta: float) -> void:
	if not is_dead:
		_update_movement(delta)

func _update_movement(delta: float) -> void:
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

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

func take_damage():
	thought.show()
	
	var thought_hearts_array: Array[CompressedTexture2D] = [
		THOUGHT_HEART_EMPTY,
		THOUGHT_HEART_QUARTER,
		THOUGHT_HEART_HALF,
		THOUGHT_HEART_THREEQUARTER,
		THOUGHT_HEART_FULL,
	]
	var oldHealth: int = health
	health -= 1
	
	thought.texture = thought_hearts_array[oldHealth]
	thought.show()
	
#	animate the damage indicator as a thought bubble
#	flash between old health and new health two times
	for i in 2:
		await get_tree().create_timer(0.2).timeout
		thought.texture = thought_hearts_array[health]
		await get_tree().create_timer(0.2).timeout
		thought.texture = thought_hearts_array[oldHealth]
	
#	set health thought icon to new health value
	thought.texture = thought_hearts_array[health]
	
	await get_tree().create_timer(0.3).timeout
	thought.hide()
	
	if (health <= 0):
		_die()
		return
	
	await get_tree().create_timer(0.8).timeout
	hurtbox.disabled = false

func _die():
	anims.play("die")
	brain.send_event("died")
	is_dead = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		var soul: MeepleSoul = MEEPLE_SOUL.instantiate()
		soul.soul_value = soul_value
		soul.position = position
		MeepPeeper.notify_meeple_unhovered(self)
		get_parent().add_child(soul)
		queue_free()

func notify_wave_started() -> void:
	brain.send_event("wave_started")
	
# region State Charts Stuff
func _on_target_reached() -> void:
	brain.send_event.call_deferred("target_reached")

func pick_room_action():
	if treasure_collected >= max_treasure:
		brain.send_event("leave_dungeon")
	if randf() < 0.8:
		brain.send_event("look_for_macguffins")
	else:
		brain.send_event("next_room")

func go_to_random_position_in_room():
	if agent_map_is_empty_or_unsynced:
		await NavigationServer2D.map_changed

	var nav_layers := compute_nav_layers()
	while true:
		set_target_position(current_room.get_random_walkable_global_position(nav_layers))
		if nav_agent.is_target_reachable():
			break

func decide_to_keep_exploring_current_room():
	if randf() < 0.5:
		brain.send_event("look_for_macguffins")
	else:
		brain.send_event("next_room")

func decide_look_for_macguffin_action():
	var scores = macguffin_strategy.get_macguffin_scores(self, _get_known_macguffins())

	if not scores.is_empty() and randf() < 0.9:
		target_macguffin = scores[0].object
		if debug:
			print("Chose Macguffin " + target_macguffin.name + ":")
			for score in scores:
				print(score._to_string())
		brain.send_event("targeted_macguffin")
	elif randf() < 0.5:
		brain.send_event("look_for_macguffins")
	else:
		brain.send_event("next_room")

func go_to_chosen_macguffin():
	set_target_position(target_macguffin.global_position)

func take_or_ignore_chosen_macguffin():
	if target_macguffin == null:
		return
		
	if randf() < 0.8:
		target_macguffin.queue_free()
		treasure_collected += 1
	
	target_macguffin = null
		
	brain.send_event("interacted_with_macguffin")

func go_to_next_room():
	var scores := explore_room_strategy.get_room_scores(self, _get_other_known_rooms())
	assert(not scores.is_empty())
	
	var next_room: Room = scores[0].object
	if debug:
		print("Chose Room " + next_room.name + ":")
		for score in scores:
			print(score._to_string())
	set_target_position(next_room.get_random_walkable_global_position(compute_nav_layers()))

func set_target_position(target_position: Vector2) -> void:
	nav_agent.navigation_layers = compute_nav_layers()
	nav_agent.target_position = target_position

func go_to_entrance():
	var entrance: Room = null
	for room in visited_rooms:
		if room is EntranceRoom:
			entrance = room
			break
	set_target_position(entrance.global_position)

func exit_dungon() -> void:
	queue_free()

func compute_nav_layers() -> int:
	return nav_flags_avoid_traps if randf() <= trap_awareness_chance else nav_flags_normal