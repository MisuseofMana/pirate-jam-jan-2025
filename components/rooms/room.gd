class_name Room extends Area2D

@onready var dungeon_controller: DungeonController = get_parent()
@onready var dungeon_tile : DungeonTile = $DungeonTile
@onready var nav_region = $NavigationRegion2D
@onready var activate_room_sfx = $ActivateRoomSFX
@onready var click_error_sfx = $ClickErrorSFX

const FOUR_EXITS = preload("res://components/rooms/nav_regions/four_exits.tres")
const NO_EXITS = preload("res://components/rooms/nav_regions/no_exits.tres")
const ONE_EXIT = preload("res://components/rooms/nav_regions/one_exit.tres")
const THREE_EXITS = preload("res://components/rooms/nav_regions/three-exits.tres")
const TWO_NEIGHBOR_EXITS = preload("res://components/rooms/nav_regions/two-neighbor-exits.tres")
const TWO_OPPOSITE_EXITS = preload("res://components/rooms/nav_regions/two_opposite_exits.tres")

var atlas_register : Dictionary = {
	"0000": {
		"dungeon_tile": preload("res://art/rooms/room_sprite0.png"),
		"nav_mesh": NO_EXITS,
		"nav_rotation": 0,
	},
	"1000": {
		"dungeon_tile": preload("res://art/rooms/room_sprite1.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": 0,
	},
	"0100": {
		"dungeon_tile": preload("res://art/rooms/room_sprite2.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": PI/2,
	},
	"0010": {
		"dungeon_tile": preload("res://art/rooms/room_sprite3.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": PI,
	},
	"0001": {
		"dungeon_tile": preload("res://art/rooms/room_sprite4.png"),
		"nav_mesh": ONE_EXIT,
		"nav_rotation": -PI/2,
	},
	"1010": {
		"dungeon_tile": preload("res://art/rooms/room_sprite5.png"),
		"nav_mesh": TWO_OPPOSITE_EXITS,
		"nav_rotation": 0,
	},
	"0101": {
		"dungeon_tile": preload("res://art/rooms/room_sprite6.png"),
		"nav_mesh": TWO_OPPOSITE_EXITS,
		"nav_rotation": PI/2,
	},
	"1100": {
		"dungeon_tile": preload("res://art/rooms/room_sprite7.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": 0,
	},
	"0110": {
		"dungeon_tile": preload("res://art/rooms/room_sprite8.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": PI/2,
	},
	"0011": {
		"dungeon_tile": preload("res://art/rooms/room_sprite9.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": PI,
	},
	"1001": {
		"dungeon_tile": preload("res://art/rooms/room_sprite10.png"),
		"nav_mesh": TWO_NEIGHBOR_EXITS,
		"nav_rotation": -PI/2,
	},
	"1101": {
		"dungeon_tile": preload("res://art/rooms/room_sprite11.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": 0,
	},
	"1110": {
		"dungeon_tile": preload("res://art/rooms/room_sprite12.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": PI/2,
	},
	"0111": {
		"dungeon_tile": preload("res://art/rooms/room_sprite13.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": PI,
	},
	"1011": {
		"dungeon_tile": preload("res://art/rooms/room_sprite14.png"),
		"nav_mesh": THREE_EXITS,
		"nav_rotation": -PI/2,
	},
	"1111": {
		"dungeon_tile": preload("res://art/rooms/room_sprite15.png"),
		"nav_mesh": FOUR_EXITS,
		"nav_rotation": 0,
	},
}

func _ready():
	dungeon_controller.changed.connect(update_room_sprite)
	update_room_sprite()
	
func update_room_sprite():
	var coords = get_coords()
		
	var possible_connections : Array[Vector2i] = [
		dungeon_controller.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_TOP_SIDE),
		dungeon_controller.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
		dungeon_controller.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),
		dungeon_controller.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	]
	
	var atlas_decode : String = ""
	
#		checks top, right, bottom, left
	for neighbor in possible_connections:
		atlas_decode += ('1' if dungeon_controller.get_cell_source_id(neighbor) >= 0 else '0')
	
	dungeon_tile.texture = atlas_register[atlas_decode]['dungeon_tile']
	nav_region.navigation_polygon = atlas_register[atlas_decode]['nav_mesh']
	nav_region.rotate(atlas_register[atlas_decode]['nav_rotation'])

func room_is_clickable() -> bool:
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
	var coords : Vector2i = get_coords()
	return dungeon_controller.last_selected_dungeon_room == coords

func handle_room_click():
	if iAmSelectedRoom():
		dungeon_controller.last_selected_dungeon_room = null
	elif not iAmSelectedRoom() and anyRoomIsActive():
		click_error_sfx.play()
	else:
		dungeon_controller.last_selected_dungeon_room = get_coords()
		activate_room_sfx.play()

func show_outline_on_mouse_enter():
	if room_is_clickable():
		dungeon_tile.make_shader_green()
		dungeon_tile.turn_on_shader()
	else:
		dungeon_tile.make_shader_red()
		dungeon_tile.turn_on_shader()

func hide_outline_on_hover_mouse_exit():
	if dungeon_controller.last_selected_dungeon_room == get_coords():
		dungeon_tile.make_shader_purple()
		return
	
	dungeon_tile.turn_off_shader()
	
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
