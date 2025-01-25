class_name DungeonRoomController extends TileMapLayer

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

var room_movement_locked: bool = false

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
