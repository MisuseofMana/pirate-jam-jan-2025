class_name DungeonController extends TileMapLayer

# will be a Vector2i or null
var last_selected_dungeon_room = null :
	set(newValue):
		var oldValue = last_selected_dungeon_room
		last_selected_dungeon_room = newValue
		handle_new_clicked_room(oldValue, newValue)
		
var room_is_selected : bool = false

func _ready():
	call_deferred("connect_empty_room_signals")

func connect_empty_room_signals():
	for emptyRoom in get_children():
		print(emptyRoom)
		if emptyRoom is EmptyRoom:
			print('connected to', emptyRoom)
			emptyRoom.room_moved_from_to.connect(relocate_room)
	
func handle_new_clicked_room(oldCoords, newCoords):
	if oldCoords is Vector2i:
		for room in get_children():
			if room is Room:
				var roomCoords = room.get_coords()
				var isOldRoom : bool = roomCoords == oldCoords
				var isNewRoom : bool = roomCoords == newCoords
				var dungeonTile : DungeonTile  = room.dungeon_tile
				if isOldRoom:
					dungeonTile.make_shader_green()
				elif isNewRoom:
					dungeonTile.make_shader_purple()
					dungeonTile.turn_on_shader()

func relocate_room(from : Vector2i, to: Vector2i):
	var scene = PackedScene.new() 
	for room in get_children():
		if room.get_coords() == from:
			scene.pack(room)
			#get_tree().create_tween().tween_property(room, "scale", 0, 0.8)
			#await get_tree().create_timer(0.8).timeout
			room.queue_free()
	
	var new_room_instance : Room = scene.instantiate()
			
	# Convert the tilemap position to world position
	new_room_instance.position = map_to_local(to)
	#new_room_instance.scale = Vector2(0, 0)
	#new_room_instance.rotation = 360
	
	# Add the scene instance to the scene tree (or to a specific parent if needed)
	add_child(new_room_instance)

	#get_tree().create_tween().tween_property(new_room_instance, "scale", 1, 0.8)
	#get_tree().create_tween().tween_property(new_room_instance, "rotation", 0, 0.8)
