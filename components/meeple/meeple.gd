class_name Meeple extends Node2D

signal info_changed
signal meep_died()

const MEEPLE_SOUL = preload("res://components/soul/meeple_soul.tscn")
const THOUGHT_HEART_EMPTY = preload("res://art/meeple/thought-heart-empty.png")
const THOUGHT_HEART_QUARTER = preload("res://art/meeple/thought-heart-quarter.png")
const THOUGHT_HEART_HALF = preload("res://art/meeple/thought-heart-half.png")
const THOUGHT_HEART_THREEQUARTER = preload("res://art/meeple/thought-heart-threequarter.png")
const THOUGHT_HEART_FULL = preload("res://art/meeple/thought-heart-full.png")

enum RoomActivity {
	TAKE_TREASURE,
	LOAF_AROUND,
	NEXT_ROOM,
}

@export var meeple_names: Array[String] = []

@export_group("Stats")
@export_range(1, 4) var health: int = 4:
	set(value):
		if value == health: return
		health = value
		info_changed.emit()
@export var movement_speed: float = 20.0
@export var max_treasure: int = 3:
	set(value):
		if value == max_treasure: return
		max_treasure = value
		info_changed.emit()
		
@export_group("Visual Modifiers")
@export var portrait: Texture
@export var tint: Color = Color(1, 1, 1, 1)

@export_group("AI")
@export var macguffin_strategy: MacguffinStrategy
@export var next_room_strategy: RoomStrategy
@export var room_activity_strategy: RoomActivityStrategy
@export_range(0, 1, 0.01) var trap_awareness_chance: float
@export_flags_2d_navigation var nav_flags_normal: int
@export_flags_2d_navigation var nav_flags_avoid_traps: int

@export_group("Internal")
@export var nav_agent: NavigationAgent2D
@export var brain: StateChart
@export var hover_hitbox: Area2D
@export var room_hitbox: Area2D
@export var trap_hitbox: Area2D
@export var hurt_audio: AudioStreamPlayer2D
@export var excited_audio: AudioStreamPlayer2D
@export var thought: ThoughtPeeper
@export var selected_particles: GPUParticles2D

@onready var anims := $AnimationPlayer
@onready var meeple_sprite := $Meeple

@onready var meeple_name: String = meeple_names.pick_random()
@onready var current_room: Room = get_parent().get_parent():
	set(value):
		if value == current_room: return
		current_room = value
		if current_room:
			current_room.add_meeple.call_deferred(self)
@onready var visited_rooms: Array[Node2D] = [current_room]
@onready var overlapping_rooms: Array[Room] = [current_room]

const DECREMENT_LABEL = preload("res://ui/decrement_label.tscn")

var debug: bool = false
var treasure_collected: int = 0:
	set(value):
		if value == treasure_collected: return
		treasure_collected = value
		info_changed.emit()
var soul_value: int = 1

var movement_delta: float
var target_room: Room = null
var target_macguffin: Node2D = null
var agent_map_is_empty_or_unsynced: bool:
	get(): return NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0
var should_move: bool = true

var is_active_meep: bool = false:
	set(value):
		is_active_meep = value
		if is_active_meep == true:
			selected_particles.emitting = true
		else:
			selected_particles.emitting = false

static func get_all_activities() -> Array[RoomActivity]:
	var activities: Array[Meeple.RoomActivity] = []
	for activity in Meeple.RoomActivity.keys():
		activities.append(Meeple.RoomActivity[activity])
	return activities

static func get_all(node_in_tree: Node) -> Array[Meeple]:
	var meeples: Array[Meeple] = []
	for child in node_in_tree.get_tree().get_nodes_in_group("meeple"):
		if child is Meeple:
			meeples.append(child)
	return meeples

func _ready() -> void:
	add_to_group("meeple")
	add_meep_to_list()

	meeple_sprite.modulate = tint
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_reached.connect(_on_target_reached)

	meeple_sprite.play("default")
	
	room_hitbox.area_entered.connect(_on_room_hitbox_entered)
	room_hitbox.area_exited.connect(_on_room_hitbox_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug_mode"):
		debug = not debug
		nav_agent.debug_enabled = debug

func add_meep_to_list() -> void:
	var new_meep_list = GameState.meeple_list
	new_meep_list.append(self)
	GameState.meeple_list = new_meep_list

func erase_meep_from_list() -> void:
	var new_meep_list = GameState.meeple_list
	new_meep_list.erase(self)
	GameState.meeple_list = new_meep_list

func _on_room_hitbox_entered(area: Area2D) -> void:
	if debug:
		print(area)
	var room := area as Room
	if room and not visited_rooms.has(room):
		overlapping_rooms.append(room)
		_on_overlapping_rooms_changed()

func _on_room_hitbox_exited(area: Area2D) -> void:
	var room := area as Room
	if room and overlapping_rooms.has(room):
		overlapping_rooms.erase(room)
		_on_overlapping_rooms_changed()

func _on_overlapping_rooms_changed() -> void:
	if overlapping_rooms.is_empty():
		return
	current_room = overlapping_rooms[-1]

func _get_enterable_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	for room in get_tree().get_nodes_in_group("room"):
		if room != current_room and room is Room and room.enterable:
			rooms.append(room)
	return rooms
	
func _physics_process(delta: float) -> void:
	if should_move:
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
	hurt_audio.play()
	thought.appear(ThoughtPeeper.Topic.HURT)

	health -= 1
	
	if (health <= 0):
		_die()
		return
	
	await get_tree().create_timer(0.8).timeout

func _die():
	anims.play("die")
	is_active_meep = false
	brain.send_event("died")
	should_move = false

func explode():
	anims.play("explode")
	brain.send_event("died")
	GameState.notify_meep_will_explode()
	should_move = false
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		var soul: MeepleSoul = MEEPLE_SOUL.instantiate()
		soul.soul_value = soul_value
		soul.position = position
		GameState.notify_peeper_select_new_meep()
		get_parent().add_child(soul)
		queue_free()
	if anim_name == 'explode':
		animate_soul_decrement_to_parchment()

func animate_soul_decrement_to_parchment():
	var decrement_node = DECREMENT_LABEL.instantiate()
	decrement_node.position = position + Vector2(-6, -50)
	decrement_node.text = str(-soul_value)
	decrement_node.soul_value = soul_value
	get_tree().root.add_child(decrement_node)
	queue_free()

func notify_room_move_start() -> void:
	should_move = false
	nav_agent.process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED
	room_hitbox.process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED
	trap_hitbox.process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED
	brain.send_event("room_move_start")

func notify_room_move_end() -> void:
	should_move = true
	nav_agent.process_mode = Node.ProcessMode.PROCESS_MODE_INHERIT
	room_hitbox.process_mode = Node.ProcessMode.PROCESS_MODE_INHERIT
	trap_hitbox.process_mode = Node.ProcessMode.PROCESS_MODE_INHERIT
	scale = Vector2.ONE
	rotation = 0
	brain.send_event("room_move_end")

func set_target_position(target_position: Vector2) -> void:
	nav_agent.navigation_layers = compute_nav_layers()
	nav_agent.target_position = target_position
	
# region State Charts Stuff
func _on_target_reached() -> void:
	brain.send_event.call_deferred("target_reached")

func pick_room_activity():
	if treasure_collected >= max_treasure:
		brain.send_event("leave_dungeon")
		return

	var result := room_activity_strategy.get_result(self)
	
	if debug:
		print(result)
	
	var target_activity := result.choice as RoomActivity
	match target_activity:
		RoomActivity.TAKE_TREASURE:
			var all_treasure := current_room.get_treasure()
			if all_treasure.is_empty():
				brain.send_event("next_room")
				return
			var treasure_result := macguffin_strategy.get_result(self, all_treasure)
			if not treasure_result.is_empty():
				target_macguffin = treasure_result.choice
				brain.send_event("take_treasure")
				if debug:
					print(treasure_result)

		RoomActivity.NEXT_ROOM:
			brain.send_event("next_room")

		RoomActivity.LOAF_AROUND:
			brain.send_event("loaf_around")

		_:
			assert(false, "Unhandled RoomActivity: " + str(target_activity))
	
func go_to_next_room():
	var result := next_room_strategy.get_result(self, _get_enterable_rooms())
	if result.is_empty():
		push_warning("No rooms to explore")
		return
	
	target_room = result.choice
	if debug:
		print(result)
	set_target_position(target_room.get_random_walkable_global_position(compute_nav_layers()))

func loaf():
	if agent_map_is_empty_or_unsynced:
		await NavigationServer2D.map_changed

	var nav_layers := compute_nav_layers()
	while true:
		set_target_position(current_room.get_random_walkable_global_position(nav_layers))
		if nav_agent.is_target_reachable():
			break
	
func go_to_chosen_macguffin():
	set_target_position(target_macguffin.global_position)

func take_chosen_macguffin():
	if target_macguffin == null:
		return
	
	if target_macguffin == get_tree().get_first_node_in_group("sword"):
		var swordRoomNode: SwordRoom = target_macguffin.owner
		swordRoomNode.initate_sword_event(self)
	elif target_macguffin is Treasure:
		target_macguffin.remove_treasure_from_group()
		treasure_collected += 1

	target_macguffin = null
		
	brain.send_event("took_treasure")

func go_to_entrance():
	var entrance: Room = null
	for room in visited_rooms:
		if room is EntranceRoom:
			entrance = room
			break
	set_target_position(entrance.global_position)

func exit_dungon() -> void:
	erase_meep_from_list()
	queue_free()
	GameState.notify_peeper_select_new_meep()

func _meep_died():
	meep_died.emit()
	erase_meep_from_list()

func compute_nav_layers() -> int:
	return nav_flags_avoid_traps if randf() <= trap_awareness_chance else nav_flags_normal

func show_thought_treasure() -> void:
	excited_audio.play()
	thought.appear(ThoughtPeeper.Topic.TREASURE)

func show_thought_thinking() -> void:
	thought.appear(ThoughtPeeper.Topic.THINKING)

func show_thought_exit() -> void:
	thought.appear(ThoughtPeeper.Topic.EXIT)
