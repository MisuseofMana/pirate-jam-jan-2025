extends Sprite2D

@onready var label: Label = $Label

func _ready():
	label.text = str(GameState.souls)
