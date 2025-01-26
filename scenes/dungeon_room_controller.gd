@tool
class_name DungeonRoomController extends TileMapLayer

@export var camera_node = Camera2D:
	set(value):
		camera_node = value
		update_configuration_warnings()
		
const EVENT_DRAW_SWORD = preload("res://components/room_events/event_draw_sword.tscn")
const MEEPLE = preload("res://components/meeple/meeple.tscn")

var room_coords: Dictionary = {}

# will be a Vector2i or null
var last_selected_dungeon_room = null:
	set(newValue):
		var oldValue = last_selected_dungeon_room
		last_selected_dungeon_room = newValue
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
	InputMap.load_from_project_settings()
	GameState.paused.connect(func(): process_mode = ProcessMode.PROCESS_MODE_DISABLED)
	GameState.resumed.connect(func(): process_mode = ProcessMode.PROCESS_MODE_ALWAYS)

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
	if Input.is_action_just_pressed("run_sword_event"):
		run_sword_event(MEEPLE.instantiate())
		
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
	get_tree().create_tween().tween_property(camera_node, "zoom", Vector2(2, 2), camera_anim_speed)
	GameState.notify_meep_drawing_sword()
	
func run_sword_event(meep_attempting_event: Meeple):
	zoom_in_on_sword()
	GameState.souls -= meep_attempting_event.soul_value
	var swordEventNode : EventDrawSword = EVENT_DRAW_SWORD.instantiate()
	var eventWrapper = Node2D.new()
	eventWrapper.position = get_sword_room_tile_position()
	get_tree().root.add_child(eventWrapper)
	eventWrapper.add_child(swordEventNode)
	swordEventNode.show_not_worthy()
	
	if GameState.souls <= 0:
		swordEventNode.show_worthy()
		GameState.notify_meep_exploded(meep_attempting_event)
	else:
		swordEventNode.show_not_worthy()
	
func reset_camera_to_origin():
	get_tree().create_tween().tween_property(camera_node, "position", Vector2(0, 0), camera_anim_speed)
	get_tree().create_tween().tween_property(camera_node, "zoom", Vector2(1, 1), camera_anim_speed)

func handle_new_clicked_room(oldCoords, newCoords):
	if newCoords:
		var clickedTile: RoomSprite = get_room_scene(newCoords).room_sprite
		#	same room was clicked and shader is already on
		if oldCoords == newCoords:
			clickedTile.make_shader_green()
		if oldCoords != newCoords:
			clickedTile.make_shader_purple()
			clickedTile.turn_on_shader()

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
	
	room_movement_locked = false
	fromNode.shrink()
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
	
	get_tree().call_group("soul", "go_to_sword")
	
	room_movement_locked = false
