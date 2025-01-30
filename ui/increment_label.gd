extends Label

var soul_value : int

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	get_tree().create_tween().tween_property(self, "position", self.position + Vector2(0, -10), 0.4)
	await get_tree().create_timer(0.4).timeout
	get_tree().create_tween().tween_property(self, "global_position", Vector2(0, -160), 0.5)
	await get_tree().create_timer(0.5).timeout
	GameState.notify_souls_increased(soul_value)
	get_tree().create_tween().tween_property(self, "modulate", Color(0, 0, 0, 0), 0.3)
	await get_tree().create_timer(0.3).timeout
	queue_free()
