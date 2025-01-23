class_name DungeonController extends TileMapLayer

# will be a Vector2i or null
var last_selected_dungeon_room = null :
	set(newValue):
		var oldValue = last_selected_dungeon_room
		last_selected_dungeon_room = newValue
		handle_new_clicked_room(oldValue, newValue)
		
var room_is_selected : bool = false

func handle_new_clicked_room(oldCoords, newCoords):
	if oldCoords is Vector2i:
		for room in get_children():
			if room is Room:
				var roomCoords = room.get_coords()
				var isOldRoom : bool = roomCoords == oldCoords
				var isNewRoom : bool = roomCoords == newCoords
				var dungeonTile : DungeonTile  = room.dungeon_tile
				if isOldRoom:
					dungeonTile.turn_off_shader()
				elif isNewRoom:
					dungeonTile.make_shader_purple()
					dungeonTile.turn_on_shader()
	
