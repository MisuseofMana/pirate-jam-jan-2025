class_name DungeonRoomController extends TileMapLayer

# will be a Vector2i or null
var last_selected_dungeon_room = null :
	set(newValue):
		var oldValue = last_selected_dungeon_room
		last_selected_dungeon_room = newValue
		handle_new_clicked_room(oldValue, newValue)
		
var room_is_selected : bool = false
var fromNode : Room
var toNode : EmptyRoom
var fromCoords : Vector2i
var toCoords : Vector2i
var tempSceneId : int

var room_movement_locked : bool = false

func handle_new_clicked_room(oldCoords, newCoords):
	if oldCoords is Vector2i:
		for room in get_children():
			if room is Room:
				var roomCoords = room.get_coords()
				var isOldRoom : bool = roomCoords == oldCoords
				var isNewRoom : bool = roomCoords == newCoords
				var dungeonTile : DungeonTile  = room.dungeon_tile
				if isOldRoom:
#					if isOldRoom, the room was already selected,
#					clicking it again should make the shader green,
#					to indicate it can be clicked again
					dungeonTile.make_shader_green()
				elif isNewRoom:
					dungeonTile.make_shader_purple()
					dungeonTile.turn_on_shader()

func get_room_node_from_coords(coords : Vector2i):
	for room in get_children():
		if room.get_coords() == coords:
			return room

func spawn_empty_room_at(coords : Vector2i):
	set_cell(coords, 0, Vector2i(0, 0), 2)

func relocate_room(from : Vector2i, to: Vector2i):
	last_selected_dungeon_room = null
	fromCoords = from
	toCoords = to
	fromNode = get_room_node_from_coords(from)
	toNode = get_room_node_from_coords(to)
	
	var packedScene = PackedScene.new()
	fromNode.position = Vector2(0,0)
	#fromNode.anims.autoplay = "grow_room"
	fromNode.dungeon_tile.turn_off_shader()
	packedScene.pack(fromNode)
	
	var packedTile = await get_tile_as_packed_scene(packedScene)
	
	set_cell(toCoords, 0, Vector2i(0,0), packedTile)
	spawn_empty_room_at(fromCoords)
	room_movement_locked = false
	
	#fromNode.anims.play('shrink_room')
	#room_movement_locked = true

func get_tile_as_packed_scene(sceneToSave : PackedScene):
	var scene_source = tile_set.get_source(0)
	if scene_source is TileSetScenesCollectionSource:
		tempSceneId = scene_source.get_next_scene_tile_id()
		return scene_source.create_scene_tile(sceneToSave, tempSceneId)
		
func clear_temp_scene_id():
	var scene_source = tile_set.get_source(0)
	if scene_source is TileSetScenesCollectionSource:
		scene_source.remove_scene_tile(tempSceneId)

func handle_animations(anim_name : StringName):
	pass
