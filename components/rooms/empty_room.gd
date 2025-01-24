class_name EmptyRoom extends Area2D

@onready var dungeon_controller: DungeonController = get_parent()
@onready var empty_dungeon_tile = $EmptyDungeonTile
@onready var click_error_sfx = $ClickErrorSFX

func _ready():
	empty_dungeon_tile.hide()

func room_is_clickable() -> bool:
#	an EmptyRoom is only clickable if a non empty Room is active
	return dungeon_controller.last_selected_dungeon_room != null

func handle_room_click():
	var coords : Vector2i = get_coords()
	if dungeon_controller.last_selected_dungeon_room:
		print('move room')
		#get the scene source
		#var source_id = dungeon_controller.get_cell_source_id(dungeon_controller.last_selected_dungeon_room)
		#if source_id > -1:
			#var scene_source = dungeon_controller.tile_set.get_source(source_id)
			#if scene_source is TileSetScenesCollectionSource:
				#var alt_id = dungeon_controller.get_cell_alternative_tile(dungeon_controller.last_selected_dungeon_room)
				#var scene = scene_source.get_scene_tile_scene(alt_id)
				#
				#dungeon_controller.set_scene_tile_scene(source_id, scene)
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
