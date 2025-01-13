extends CanvasLayer

@onready var button = $Control/Button

func show_button():
	button.show()
	
func _on_button_pressed():
	SceneSwitcher.switch_scene("res://scenes/start-screen.tscn")
