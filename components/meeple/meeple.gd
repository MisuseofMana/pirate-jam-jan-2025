class_name Meeple extends Node2D

#@export var stats : MeepleStats
@onready var thought: Sprite2D = $Thought
@onready var anims = $AnimationPlayer
@onready var hurtbox = $TrapHitbox/CollisionShape2D
@onready var meeple_sprite = $Meeple
@onready var soul_sprite = $Soul

@export_group("Visuals")
@export var meeple_skin: SpriteFrames = preload("res://components/meeple/meeple_skin_looter.tres")
@export_group("Stats")
@export_range(1, 4) var health: int = 4
@export_range(0, 1, 0.1) var greed: float = 0.1
@export_range(0, 1, 0.1) var piety: float = 0.1
@export_range(1, 99) var soul_value : int = 1
@export var movement_speed: float = 20.0

@export_group("AI")
@export var macguffin_strategy: MacguffinStrategy
@export var explore_room_strategy: RoomStrategy

@export_group("Internal")
@export var nav_agent: NavigationAgent2D
@export var brain: StateChart

const THOUGHT_HEART_EMPTY = preload("res://art/meeple/thought-heart-empty.png")
const THOUGHT_HEART_QUARTER = preload("res://art/meeple/thought-heart-quarter.png")
const THOUGHT_HEART_HALF = preload("res://art/meeple/thought-heart-half.png")
const THOUGHT_HEART_THREEQUARTER = preload("res://art/meeple/thought-heart-threequarter.png")
const THOUGHT_HEART_FULL = preload("res://art/meeple/thought-heart-full.png")

signal die(whoDied)

var movement_delta: float

@onready var current_room: Room = get_parent()
@onready var overlapping_rooms: Array[Room] = [current_room]
@onready var visited_rooms: Array[Node2D] = [current_room]

var target_macguffin: Node2D = null

var agent_map_is_empty_or_unsynced: bool:
	get(): return NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0

func _ready() -> void:
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_reached.connect(_on_target_reached)
	thought.hide()
	meeple_sprite.sprite_frames = meeple_skin
	meeple_sprite.play("default")

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
		await get_tree().create_timer(0.1).timeout
		thought.texture = thought_hearts_array[health]
		await get_tree().create_timer(0.1).timeout
		thought.texture = thought_hearts_array[oldHealth]
	
#	set health thought icon to new health value
	thought.texture = thought_hearts_array[health]
	
	await get_tree().create_timer(0.3).timeout
	thought.hide()
	
	if (health <= 0):
		anims.play("die")
#		early return if dead to prevent re-enabling hurtbox
		return
	
	await get_tree().create_timer(0.8).timeout
	hurtbox.disabled = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		die.emit(self)
		meeple_sprite.hide()
		brain.send_event("become_soul")
		print('reached become_soul')
		
func become_soul():
	soul_sprite.show()
	soul_sprite.play("spawn_soul")
	brain.send_event("go_to_sword")
	
func go_to_sword():
	nav_agent.target_position = get_tree().get_first_node_in_group("sword").global_position

func tithe_soul():
	GameState.souls += soul_value
#	destroy self
	
# region State Charts Stuff
func _on_target_reached() -> void:
	brain.send_event.call_deferred("target_reached")

func pick_room_action():
	if randf() < 0.5:
		brain.send_event("look_for_macguffins")
	elif randf() < 0.2:
		brain.send_event("leave_dungeon")
	else:
		brain.send_event("next_room")

func go_to_random_position_in_room():
	var margin := 16

	if agent_map_is_empty_or_unsynced:
		await NavigationServer2D.map_changed

	while true:
		var width := 64.
		var height := 64
		nav_agent.target_position = current_room.global_position + Vector2(
			-width / 2.0 + randf_range(margin, width - margin * 2),
			-height / 2.0 + randf_range(margin, height - margin * 2)
		)
		if nav_agent.is_target_reachable():
			break

func decide_to_keep_exploring_current_room():
	if randf() < 0.5:
		brain.send_event("look_for_macguffins")
	else:
		brain.send_event("next_room")

func decide_look_for_macguffin_action():
	var macguffin = macguffin_strategy.select_macguffin(self, _get_known_macguffins())
	if macguffin and randf() < 0.5:
		target_macguffin = macguffin
		brain.send_event("targeted_macguffin")
	elif randf() < 0.5:
		brain.send_event("look_for_macguffins")
	else:
		brain.send_event("next_room")

func go_to_chosen_macguffin():
	nav_agent.target_position = target_macguffin.global_position

func take_or_ignore_chosen_macguffin():
	if target_macguffin == null:
		return
		
	if randf() < 0.5:
		target_macguffin.queue_free()
	
	target_macguffin = null
		
	brain.send_event("interacted_with_macguffin")

func go_to_next_room():
	var next_room := explore_room_strategy.select_room(self, _get_other_known_rooms())
	nav_agent.target_position = next_room.global_position

func go_to_entrance():
	var entrance: Room = null
	for room in visited_rooms:
		if room is EntranceRoom:
			entrance = room
			break
	nav_agent.target_position = entrance.global_position

func exit_dungon() -> void:
	queue_free()
	
