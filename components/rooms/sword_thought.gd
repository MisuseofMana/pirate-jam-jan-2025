extends Sprite2D

@onready var label: Label = $Label

func _ready():
	GameState.souls_changed.connect(update_soul_label)
	label.text = str(GameState.souls)

func update_soul_label(newValue):
	label.text = str(newValue)
