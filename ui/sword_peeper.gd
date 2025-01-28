class_name SwordPeeper extends Control

@export_group("References")
@export var soul_value_label: Label
@onready var timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	GameState.souls_changed.connect(_on_souls_changed)
	_update(GameState.souls)

func _on_souls_changed(souls: int):
	_update(souls)
	
func _update(souls: int):
	soul_value_label.text = str(GameState.souls) + ' / ' + str(99)

func _on_timer_timeout():
	animation_player.play("collapse")
