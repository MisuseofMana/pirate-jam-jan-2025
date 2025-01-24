class_name EmptyRoom extends Area2D

@onready var dungeon_controller: DungeonController = get_parent()
@onready var empty_dungeon_tile = $EmptyDungeonTile
@onready var click_error_sfx = $ClickErrorSFX

signal room_moved_from_to(fromCoords : Vector2i, toCoords : Vector2i)

func _ready():
	empty_dungeon_tile.hide()

func room_is_clickable() -> bool:
#	an EmptyRoom is only clickable if a non empty Room is active
	return dungeon_controller.last_selected_dungeon_room != null

func handle_room_click():
	var coords : Vector2i = get_coords()
	if dungeon_controller.last_selected_dungeon_room:
		room_moved_from_to.emit(dungeon_controller.last_selected_dungeon_room, coords)
		dungeon_controller.last_selected_dungeon_room = null
	else:
		click_error_sfx.play()

func show_outline_on_mouse_enter():
	empty_dungeon_tile.show()
	if room_is_clickable():
		empty_dungeon_tile.make_shader_green()
		empty_dungeon_tile.turn_on_shader()
	else:
		empty_dungeon_tile.make_shader_red()
		empty_dungeon_tile.turn_on_shader()

func hide_outline_on_hover_mouse_exit():
	empty_dungeon_tile.hide()
	empty_dungeon_tile.turn_off_shader()
	
func get_coords() -> Vector2i:
	return dungeon_controller.local_to_map(dungeon_controller.to_local(global_position))
