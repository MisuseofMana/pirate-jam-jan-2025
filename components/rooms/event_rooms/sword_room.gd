class_name SwordRoom extends Room

signal sword_interacted_with(meeple_node : Meeple)

func _ready():
	room_sprite.turn_off_shader()
	call_deferred("update_own_tile_connections")
	GameState.sword_room_node = self

func initate_sword_event(meeple_interacting : Meeple):
	sword_interacted_with.emit(meeple_interacting)

func handle_room_click():
	click_error_sfx.play()
	
func room_is_clickable():
	return false
