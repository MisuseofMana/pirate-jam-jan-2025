class_name SwordRoom extends Room

signal sword_interacted_with(meeple_node : Meeple, sword_room_node : SwordRoom)
signal you_lost()
signal you_survived()

@onready var text_anims = $Control/TextAnimations

func initate_sword_event(meeple_interacting : Meeple):
	sword_interacted_with.emit(meeple_interacting, self)

func show_not_worthy():
	text_anims.play("unworthy")
	
func show_worthy():
	text_anims.play("worthy")

func _on_text_animations_animation_finished(anim_name):
	if anim_name == "worthy":
		you_lost.emit()
		print('you lose')
	if anim_name == "unworthy":
		print('explode meep and dont spawn a soul!')
		you_survived.emit()
