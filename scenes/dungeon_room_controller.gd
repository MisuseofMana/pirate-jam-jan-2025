class_name DungeonRoomController extends TileMapLayer

@export var camera_node = Camera2D

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

@export var camera_anim_speed : float = 0.2

var room_movement_locked : bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("trigger_sword_event"):
		run_sword_event()
	if Input.is_action_just_pressed("reset_camera"):
		reset_camera_to_origin()
		
func _enter_tree():
	child_entered_tree.connect(_register_child)

func _register_child(child):
	await child.ready
	var coords = local_to_map(to_local(child.global_position))
	child.set_meta("coords", coords)
	room_coords[coords] = child
	
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

func run_sword_event():
	get_tree().create_tween().tween_property(camera_node, "position", get_sword_room_tile_position(), camera_anim_speed)
	get_tree().create_tween().tween_property(camera_node, "zoom", Vector2(2, 2), camera_anim_speed)
	
func reset_camera_to_origin():
	get_tree().create_tween().tween_property(camera_node, "position", Vector2(0, 0), camera_anim_speed)
	get_tree().create_tween().tween_property(camera_node, "zoom", Vector2(1, 1), camera_anim_speed)

func attempt_to_take_the_sword():
	pass
	# compare sword soul value to meeples worth
	# reduce sword souls by meeple worth
	# if zero souls after contest show YOU ARE DEEMED WORTHY!
	# if more than zero souls show YOU ARE UNWORTHY!
	# explode meeple, deny soul from spawning

func handle_new_clicked_room(oldCoords, newCoords):
	if newCoords:
		print(newCoords)
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
	
	room_movement_locked = false
