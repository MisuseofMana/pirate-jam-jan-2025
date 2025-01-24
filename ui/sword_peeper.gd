class_name SwordPeeper extends Control

@export_group("References")
@export var soul_value_label: Label
@onready var timer = $Timer

func _ready():
	GameState.souls_changed.connect(_on_souls_changed)
	_update(GameState.souls)
	hide()

func _on_souls_changed(souls: int):
	_update(souls)
	
func _update(souls: int):
	show()
	soul_value_label.text = str(GameState.souls)
	timer.start()
	
func _on_timer_timeout():
	hide()
