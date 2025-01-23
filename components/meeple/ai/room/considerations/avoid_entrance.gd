class_name AvoidEntranceRoomConsideration extends RoomConsideration

func _get_room_score(_meeple: Meeple, room: Room) -> float:
	return 0.0 if room is EntranceRoom else 1.0

func _description():
	return "Avoid Entrance"
