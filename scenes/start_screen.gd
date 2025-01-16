extends CanvasLayer

func _on_button_pressed():
	SceneSwitcher.switch_scene("res://scenes/logo_screen.tscn")

func _on_secret_button_pressed():
	SceneSwitcher.switch_scene("res://scenes/secret_scene.tscn")
