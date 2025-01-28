class_name EmptyRoom extends Area2D

@onready var dungeon_controller: DungeonRoomController = get_parent()
@onready var click_error_sfx = $ClickErrorSFX
@onready var swirl_sprite: AnimatedSprite2D = $SwirlingEmptyIndicator
@onready var gpu_particles_2d: GPUParticles2D = $SwirlingEmptyIndicator/GPUParticles2D

signal room_moved_from_to(fromCoords : Vector2i, toCoords : Vector2i)

const SWIRL_PARTICLE_GREEN = preload("res://art/rooms/swirl_particle_green.png")
const SWIRL_PARTICLE_PURPLE = preload("res://art/rooms/swirl_particle_purple.png")

var empty_rooms_active = false

func _ready():
	room_moved_from_to.connect(dungeon_controller.relocate_room)

func handle_empty_cell_click():
	var coords : Vector2i = get_coords()
	if dungeon_controller.last_selected_dungeon_room != null:
		room_moved_from_to.emit(dungeon_controller.last_selected_dungeon_room, coords)
		dungeon_controller.last_selected_dungeon_room = null
	else:
		click_error_sfx.play()
		
func show_spiral_indicator():
	empty_rooms_active = true
	swirl_sprite.modulate = Color(0.928, 0.001, 0.931)
	swirl_sprite.show()
	gpu_particles_2d.emitting = false
	
func hide_spiral_indicator():
	empty_rooms_active = false
	swirl_sprite.hide()
	gpu_particles_2d.emitting = false

func show_outline_on_mouse_enter():
	if empty_rooms_active:
		swirl_sprite.modulate = Color(0, 0.999, 0)
		gpu_particles_2d.emitting = true

func hide_outline_on_hover_mouse_exit():
	swirl_sprite.modulate = Color(0.928, 0.001, 0.931)
	gpu_particles_2d.emitting = false
	
func get_coords() -> Vector2i:
	return dungeon_controller.local_to_map(dungeon_controller.to_local(global_position))
