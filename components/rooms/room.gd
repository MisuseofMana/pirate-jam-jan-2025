class_name Room extends Area2D

@onready var dungeon_controller: DungeonRoomController = get_parent()
@onready var room_sprite : RoomSprite = $DungeonTile
@onready var nav_region = $NavigationRegion2D
@onready var activate_room_sfx = $ActivateRoomSFX
@onready var click_error_sfx = $ClickErrorSFX
@onready var anims = $AnimationPlayer

signal requested_neighbors_update_connections(neighbor_tiles : Array[Vector2i])

const FOUR_EXITS = preload("res://components/rooms/nav_regions/four_exits.tres")
const NO_EXITS = preload("res://components/rooms/nav_regions/no_exits.tres")
const ONE_EXIT = preload("res://components/rooms/nav_regions/one_exit.tres")
const THREE_EXITS = preload("res://components/rooms/nav_regions/three-exits.tres")
const TWO_NEIGHBOR_EXITS = preload("res://components/rooms/nav_regions/two-neighbor-exits.tres")
const TWO_OPPOSITE_EXITS = preload("res://components/rooms/nav_regions/two_opposite_exits.tres")

var atlas_register : Dictionary = {
	"0000": {
		"name": 'No Exits',
		"room_sprite": preload("res://art/rooms/room_sprite0.png"),
		"nav_mesh": NO_EXITS,
		"nav_rotation": 0,
	},
	"0001": {
		"name": 'Top Exit',
		"room_sprite": preload("res://art/rooms/room_sprite1.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": 0,
	},
	"1000": {
		"name": 'Right Exit',
		"room_sprite": preload("res://art/rooms/room_sprite2.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": PI/2,
	},
	"0100": {
		"name": 'Bottom Exit',
		"room_sprite": preload("res://art/rooms/room_sprite3.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": PI,
	},
	"0010": {
		"name": 'Left Exit',
		"room_sprite": preload("res://art/rooms/room_sprite4.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": -PI/2,
	},
	"0101": {
		"name": '2 Vertical Exits',
		"room_sprite": preload("res://art/rooms/room_sprite5.png"),
		"nav_mesh": TWO_OPPOSITE_EXITS,
		"nav_rotation": 0,
	},
	"1010": {
		"name": '2 Horizontal Exits',
		"room_sprite": preload("res://art/rooms/room_sprite6.png"),
		"nav_mesh": TWO_OPPOSITE_EXITS,
		"nav_rotation": PI/2,
	},
	"1001": {
		"name": 'NE Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite7.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": 0,
	},
	"1100": {
		"name": 'ES Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite8.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": PI/2,
	},
	"0110": {
		"name": 'SW Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite9.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": PI,
	},
	"0011": {
		"name": 'WN Elbow Exits',
		"room_sprite": preload("res://art/rooms/room_sprite10.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": -PI/2,
	},
	"1011": {
		"name": 'WNE T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite11.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": 0,
	},
	"1101": {
		"name": 'NES T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite12.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": PI/2,
	},
	"1110": {
		"name": 'WES T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite13.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": PI,
	},
	"0111": {
		"name": 'SWN T Exits',
		"room_sprite": preload("res://art/rooms/room_sprite14.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": -PI/2,
	},
	"1111": {
		"name": 'All Exits',
		"room_sprite": preload("res://art/rooms/room_sprite15.png"),
		"nav_mesh": FOUR_EXITS,
		"nav_rotation": 0,
	},
}

func _ready():
	room_sprite.turn_off_shader()
	anims.animation_finished.connect(dungeon_controller.handle_animations)
	call_deferred("update_own_tile_connections")

func update_own_tile_connections():
	var coords = get_coords()
		
	var possible_connections : Array[Vector2i] = dungeon_controller.get_surrounding_cells(coords)
	
	var atlas_decode : String = ""
	
#		checks left, right, top, bottom
	for neighbor in possible_connections:
		if dungeon_controller.get_room_scene(neighbor) is Room:
			atlas_decode += '1'
		else:
			atlas_decode += '0'
	#
	room_sprite.texture = atlas_register[atlas_decode]['room_sprite']
	#nav_region.navigation_polygon = atlas_register[atlas_decode]['nav_mesh']
	#nav_region.rotate(atlas_register[atlas_decode]['nav_rotation'])

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
	var count: int = 0
	for child in get_children():
		if child is Trap:
			count += 1
	return count

func get_meeples() -> Array[Meeple]:
	var meeples: Array[Meeple] = []
	for meeple in Meeple.get_all(self):
		if meeple.current_room == self:
			meeples.append(meeple)
	return meeples

func get_random_walkable_local_position() -> Vector2:
	var margin := 16
	var width := 64
	var height := 64
	return Vector2(
		-width / 2.0 + randf_range(margin, width - margin * 2),
		-height / 2.0 + randf_range(margin, height - margin * 2)
	) 

func get_random_walkable_global_position() -> Vector2:
	return global_position + get_random_walkable_local_position()
