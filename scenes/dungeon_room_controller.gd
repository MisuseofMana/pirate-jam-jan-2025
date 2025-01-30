@tool
class_name DungeonRoomController extends TileMapLayer

@export var camera_node = Camera2D:
	set(value):
		camera_node = value
		update_configuration_warnings()
		
const EVENT_DRAW_SWORD = preload("res://components/room_events/event_draw_sword.tscn")

var room_coords: Dictionary = {}

# will be a Vector2i or null
var last_selected_dungeon_room = null:
	set(newValue):
		var oldValue = last_selected_dungeon_room
		last_selected_dungeon_room = newValue
		if newValue is Vector2i:
			handle_new_clicked_room(oldValue, newValue)

var fromCoords: Vector2i
var toCoords: Vector2i
var fromNode: Room
var toNode: EmptyRoom
var tempSceneId: int
var fromPosition: Vector2
var toPosition: Vector2

@export var camera_anim_speed: float = 0.2

var room_movement_locked: bool = false
		
func _ready() -> void:
	GameState.dungeon_controller = self
	InputMap.load_from_project_settings()
	GameState.paused.connect(func(): process_mode = ProcessMode.PROCESS_MODE_DISABLED)
	GameState.resumed.connect(func(): process_mode = ProcessMode.PROCESS_MODE_ALWAYS)
	generate_new_dungeon()

func get_random_rooms() -> Array[int]:
	var basic_room_ids : Array[int] = [4, 5, 10, 12]
	var treasure_room_ids : Array[int] = [3, 13, 16]
	var trap_room_ids : Array[int] = [1, 6, 7, 8, 15]
	var empty_room_ids : Array[int] = [2, 2, 2, 2, 2]
	
	var selected_rooms : Array[int] = []
	
	basic_room_ids.shuffle()
	treasure_room_ids.shuffle()
	trap_room_ids.shuffle()
	
	selected_rooms.append_array(basic_room_ids.slice(0, 2))
	selected_rooms.append_array(treasure_room_ids.slice(0, 2))
	selected_rooms.append_array(trap_room_ids.slice(0, 4))
	selected_rooms.append_array(empty_room_ids)
	
	return selected_rooms
	
func generate_new_dungeon():
	var valid_coords : Array[Vector2i] = [
		Vector2i(-3, -2),
		Vector2i(-2, -2),
		Vector2i(-1, -2),
		Vector2i(0, -2),
		Vector2i(1, -2),
		Vector2i(-3, -1),
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-3, 0),
		Vector2i(-2, 0),
		Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(1, 0)
	]

	valid_coords.shuffle()
	
	var random_room_ids : Array[int] = get_random_rooms()
	
	for coord : Vector2i in valid_coords: 
		set_cell(coord, 0, Vector2i(0, 0), random_room_ids.pop_front())
		
func _get_configuration_warnings():
	if camera_node == null:
		return ["A Camera2D Node must be assigned in the inspector exports."]
	else:
		return []

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("camera_to_sword"):
		zoom_in_on_sword()
	if Input.is_action_just_pressed("reset_camera"):
		reset_camera_to_origin()
		
func _enter_tree():
	child_entered_tree.connect(_register_child)

func _register_child(child):
	await child.ready
	var coords = local_to_map(to_local(child.global_position))
	child.set_meta("coords", coords)
	room_coords[coords] = child
	if child is SwordRoom:
		child.sword_interacted_with.connect(run_sword_event)
	
func update_room_coords(from: Vector2i, to: Vector2i):
	room_coords[to] = fromNode
	room_coords[from] = toNode
	fromNode.set_meta("coords", to)
	toNode.set_meta("coords", from)

func get_room_scene(coords: Vector2i) -> Node:
	return room_coords.get(coords, null)
	
func get_sword_room_tile_position():
	for child in get_children():
		if child is SwordRoom:
			return to_global(map_to_local(child.get_coords()))
			
func get_sword_room_tile_coords():
	for child in get_children():
		if child is SwordRoom:
			return child.get_coords()

func zoom_in_on_sword():
	get_tree().create_tween().tween_property(camera_node, "position", get_sword_room_tile_position(), camera_anim_speed)
	get_tree().create_tween().tween_property(camera_node, "zoom", Vector2(1.5, 1.5), camera_anim_speed)
	
func run_sword_event(meep_attempting_event: Meeple):
	zoom_in_on_sword()
	GameState.notify_meep_drawing_sword()
	var swordEventNode: EventDrawSword = EVENT_DRAW_SWORD.instantiate()
	var eventWrapper = Node2D.new()
	eventWrapper.position = get_sword_room_tile_position()
	get_tree().root.add_child(eventWrapper)
	eventWrapper.add_child(swordEventNode)
	
	var newSoulValue = GameState.souls - meep_attempting_event.soul_value
	
	if newSoulValue <= 0:
		swordEventNode.show_worthy()
	else:
		swordEventNode.show_not_worthy(meep_attempting_event, self)

func reset_camera_to_origin():
	get_tree().create_tween().tween_property(camera_node, "position", Vector2(0, 0), camera_anim_speed)
	get_tree().create_tween().tween_property(camera_node, "zoom", Vector2(1, 1), camera_anim_speed)

func handle_new_clicked_room(oldCoords, newCoords):
	# check that new coords are Vector2i
	if newCoords is Vector2i:
		var clickedTile: RoomSprite = get_room_scene(newCoords).room_sprite
		set_room_to_active_state(clickedTile)
	else:
		var oldTile: RoomSprite = get_room_scene(oldCoords).room_sprite
		set_room_to_available_state(oldTile)

func set_room_to_active_state(room: RoomSprite):
	room.make_shader_purple()
	room.turn_on_shader()
	activate_empty_rooms()
	
func set_room_to_available_state(room: RoomSprite):
	room.make_shader_green()
	disable_empty_rooms()

func activate_empty_rooms():
	for room_node in get_children():
		if room_node is EmptyRoom:
			room_node.show_spiral_indicator()
		
func disable_empty_rooms():
	for room_node in get_children():
		if room_node is EmptyRoom:
			room_node.hide_spiral_indicator()

func spawn_empty_room_at(coords: Vector2i):
	set_cell(coords, 0, Vector2i(0, 0), 2)

func relocate_room(from: Vector2i, to: Vector2i):
	last_selected_dungeon_room = null
	
	fromCoords = from
	toCoords = to
	
	fromNode = get_room_scene(from)
	toNode = get_room_scene(to)
	
	fromPosition = map_to_local(from)
	toPosition = map_to_local(to)
	
	fromNode.shrink()
	disable_empty_rooms()
	room_movement_locked = true
	await fromNode.shrunk

	update_room_coords(fromCoords, toCoords)
	fromNode.position = toPosition
	toNode.position = fromPosition

	fromNode.update_own_tile_connections()
	
	var neighborsToNewCellCoords: Array[Vector2i]
	neighborsToNewCellCoords.append_array(get_surrounding_cells(fromNode.get_coords()))
	neighborsToNewCellCoords.append_array(get_surrounding_cells(toNode.get_coords()))
	
	for tilecoord in neighborsToNewCellCoords:
		var roomOrEmptyNode = get_room_scene(tilecoord)
		if roomOrEmptyNode is Room:
			roomOrEmptyNode.update_own_tile_connections()
		
	fromNode.grow()
	await fromNode.grew
	room_movement_locked = false
	
	get_tree().call_group("soul", "go_to_sword")
