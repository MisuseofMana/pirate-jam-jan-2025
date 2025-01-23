class_name EmptyRoomClickDetection extends Area2D

signal empty_room_tile_clicked()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			empty_room_tile_clicked.emit()
