class_name Room extends Area2D

@onready var dungeon_controller: DungeonRoomController = get_parent()
@onready var room_sprite: RoomSprite = $DungeonTile
@onready var activate_room_sfx = $ActivateRoomSFX
@onready var click_error_sfx = $ClickErrorSFX
@onready var anims = $AnimationPlayer

signal shrunk
signal grew

var atlas_register: Dictionary = {
	"0000": {
		"name": 'No Exits',
		"room_sprite": preload("res://art/rooms/room_sprite0.png"),
	},
	"0001": {
		"name": 'Top Exit',
		"room_sprite": preload("res://art/rooms/room_sprite1.png"),
	},
	"1000": {
		"name": 'Right Exit',
		"room_sprite": preload("res://art/rooms/room_sprite2.png"),
	},
	"0100": {
		"name": 'Bottom Exit',
		"room_sprite": preload("res://art/rooms/room_sprite3.png"),
	},
	"0010": {
		"name": 'Left Exit',
		"room_sprite": preload("res://art/rooms/room_sprite4.png"),
	},
	"0101": {
		"name": '2 Vertical Exits',
		"room_sprite": preload("res://art/rooms/room_sprite5.png"),
	},
	"1010": {
		"name": '2 Horizontal Exits',
		"room_sprite": preload("res://art/rooms/room_sprite6.png"),
	},
	"1001": {
		"name": 'NE Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite7.png"),
	},
	"1100": {
		"name": 'ES Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite8.png"),
	},
	"0110": {
		"name": 'SW Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite9.png"),
	},
	"0011": {
		"name": 'WN Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite10.png"),
	},
	"1011": {
		"name": 'WNE T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite11.png"),
	},
	"1101": {
		"name": 'NES T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite12.png"),
	},
	"1110": {
		"name": 'WES T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite13.png"),
	},
	"0111": {
		"name": 'SWN T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite14.png"),
	},
	"1111": {
		"name": 'All Exits',
		"room_sprite": preload("res://art/rooms/room_sprite15.png"),
	},
}

var enterable := true

func _ready():
	room_sprite.turn_off_shader()
	anims.animation_finished.connect(_on_animation_finished)
	call_deferred("update_own_tile_connections")

func update_own_tile_connections():
	var coords = get_coords()
		
	var possible_connections: Array[Vector2i] = dungeon_controller.get_surrounding_cells(coords)
	
	var atlas_decode: String = ""
	
#		checks left, right, top, bottom
	for neighbor in possible_connections:
		if dungeon_controller.get_room_scene(neighbor) is Room:
			atlas_decode += '1'
		else:
			atlas_decode += '0'

	room_sprite.texture = atlas_register[atlas_decode]['room_sprite']

func room_is_clickable() -> bool:
	if dungeon_controller.room_movement_locked:
		return false
	if anyRoomIsActive() and not iAmSelectedRoom():
		return false
		
	if anyRoomIsActive() and iAmSelectedRoom():
		return true
	
	if not anyRoomIsActive():
		return true
		
	return true

func anyRoomIsActive() -> bool:
	return dungeon_controller.last_selected_dungeon_room != null

func iAmSelectedRoom() -> bool:
	return dungeon_controller.last_selected_dungeon_room == get_coords()

func handle_room_click():
	if dungeon_controller.room_movement_locked:
		click_error_sfx.play()
	if iAmSelectedRoom():
		dungeon_controller.last_selected_dungeon_room = null
	elif not iAmSelectedRoom() and anyRoomIsActive():
		click_error_sfx.play()
	else:
		dungeon_controller.last_selected_dungeon_room = get_coords()
		room_sprite.make_shader_purple()
		activate_room_sfx.play()

func show_outline_on_mouse_enter():
	if room_is_clickable():
		room_sprite.make_shader_green()
		room_sprite.turn_on_shader()
	else:
		room_sprite.make_shader_red()
		room_sprite.turn_on_shader()

func hide_outline_on_hover_mouse_exit():
	if dungeon_controller.last_selected_dungeon_room == get_coords():
		room_sprite.make_shader_purple()
		return
	
	room_sprite.turn_off_shader()
	
func get_coords() -> Vector2i:
	return dungeon_controller.local_to_map(dungeon_controller.to_local(global_position))
	
func is_adjacent_to(other: Room) -> bool:
	return get_coords().distance_to(other.get_coords()) == 1

func get_treasure_count() -> int:
	var count: int = 0
	for child in get_children():
		if child is Treasure:
			count += 1
	return count

func get_danger_count() -> int:
	return get_traps().size()

func get_meeples() -> Array[Meeple]:
	var meeples: Array[Meeple] = []
	for meeple in Meeple.get_all(self):
		if meeple.current_room == self:
			meeples.append(meeple)
	return meeples

func get_meeple_count() -> int:
	return get_meeples().size()

func get_traps() -> Array[Trap]:
	var traps: Array[Trap] = []
	for child in room_sprite.get_children():
		if child is Trap:
			traps.append(child)
	return traps

func get_treasure() -> Array[Treasure]:
	var treasure: Array[Treasure] = []
	for child in room_sprite.get_children():
		if child is Treasure:
			treasure.append(child)
	return treasure

func get_nav_regions() -> Array[NavigationRegion2D]:
	var regions: Array[NavigationRegion2D] = []
	for child in get_children():
		if child is NavigationRegion2D:
			regions.append(child)
	return regions

func get_random_walkable_local_position(nav_layers: int = MathUtil.MAX_INT) -> Vector2:
	var margin := 10
	var width := 64
	var height := 64

	var regions := get_nav_regions()

	while true:
		var local_pos := Vector2(
			randf_range(-width / 2.0 + margin, width / 2.0 - margin),
			randf_range(-height / 2.0 + margin, height / 2.0 - margin)
		)
		if regions.is_empty():
			return local_pos

		var global_pos := global_position + local_pos
		for region in regions:
			var nav_layers_match := (nav_layers & region.navigation_layers) == region.navigation_layers
			if nav_layers_match and NavigationServer2D.region_owns_point(region.get_region_rid(), global_pos):
				return local_pos
	
	return ErrorUtil.assert_unreachable()

func get_random_walkable_global_position(nav_layers: int = MathUtil.MAX_INT) -> Vector2:
	return global_position + get_random_walkable_local_position(nav_layers)

func add_meeple(meeple: Meeple) -> void:
	meeple.reparent(room_sprite)

func shrink() -> void:
	for meeple in get_meeples():
		meeple.notify_room_move_start()
	enterable = false
	anims.play("shrink_room")

func grow() -> void:
	anims.play("grow_room")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "shrink_room":
		room_sprite.turn_off_shader()
		shrunk.emit()
	elif anim_name == "grow_room":
		enterable = true
		grew.emit()
		for meeple in get_meeples():
			meeple.notify_room_move_end()
