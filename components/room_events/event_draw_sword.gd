class_name EventDrawSword extends Control

@onready var text_anims: AnimationPlayer = $TextAnimations

var meep_target: Meeple
var dungeon_controller: DungeonRoomController

func show_not_worthy(meep_to_target: Meeple, dung_controller: DungeonRoomController):
	text_anims.play("unworthy")
	meep_target = meep_to_target
	dungeon_controller = dung_controller
	
func show_worthy():
	text_anims.play("worthy")

func _on_text_animations_animation_finished(anim_name):
	if anim_name == "worthy":
		GameState.notify_meep_drew_sword()
	if anim_name == "unworthy":
		meep_target.explode()
		dungeon_controller.reset_camera_to_origin()
		get_parent().queue_free()
