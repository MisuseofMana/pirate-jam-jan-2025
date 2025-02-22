class_name Room extends Area2D

@onready var dungeon_controller: DungeonRoomController = get_parent()
@onready var room_sprite: RoomSprite = $DungeonTile
@onready var activate_room_sfx := $ActivateRoomSFX
@onready var click_error_sfx := $ClickErrorSFX
@onready var anims := $AnimationPlayer

@export var collision_shape: CollisionShape2D
@export var click_collision_shape: CollisionShape2D

signal shrunk
signal grew
signal room_selected
signal room_deselected

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
	#if dungeon_controller.room_movement_locked:
		#return false
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
	#if dungeon_controller.room_movement_locked:
		#click_error_sfx.play()
		#return
	if iAmSelectedRoom():
		dungeon_controller.disable_empty_rooms()
		dungeon_controller.last_selected_dungeon_room = null
		room_sprite.make_shader_green()
		room_deselected.emit()
	elif not iAmSelectedRoom() and anyRoomIsActive():
		click_error_sfx.play()
	else:
		dungeon_controller.last_selected_dungeon_room = get_coords()
		room_sprite.make_shader_purple()
		activate_room_sfx.play()
		room_selected.emit()

func show_outline_on_mouse_enter():
	if room_is_clickable():
		room_sprite.make_shader_green()
		room_sprite.turn_on_shader()
	else:
		room_sprite.turn_off_shader()

func hide_outline_on_hover_mouse_exit():
	if iAmSelectedRoom():
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
		if child.is_in_group("macguffin"):
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

func get_treasure() -> Array[Node2D]:
	var treasure: Array[Node2D] = []
	for child in room_sprite.get_children():
		if child.is_in_group("macguffin"):
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
	collision_shape.disabled = true
	click_collision_shape.disabled = true
	for meeple in get_meeples():
		meeple.notify_room_move_start()
	enterable = false
	anims.play("shrink_room")

func _on_shrunk() -> void:
	room_sprite.turn_off_shader()
	shrunk.emit()

func grow() -> void:
	anims.play("grow_room")

func _on_grew() -> void:
	collision_shape.disabled = false
	click_collision_shape.disabled = false
	enterable = true
	grew.emit()
	for meeple in get_meeples():
		meeple.notify_room_move_end()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "shrink_room":
		_on_shrunk()
	elif anim_name == "grow_room":
		_on_grew()
