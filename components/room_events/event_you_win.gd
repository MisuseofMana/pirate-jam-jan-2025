class_name EventYouWin extends Control

@onready var text_anims: AnimationPlayer = $TextAnimations

var meep_target: Meeple
var dungeon_controller: DungeonRoomController
	
func _ready():
	text_anims.play("win")

func _on_text_animations_animation_finished(anim_name):
	if anim_name == "win":
		GameState.notify_won_game()
