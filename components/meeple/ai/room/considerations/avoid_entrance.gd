class_name AvoidEntranceRoomConsideration extends RoomConsideration

func _get_room_score(_meeple: Meeple, room: Room) -> float:
	return score_if_true(room is EntranceRoom)

func _description():
	return "Avoid Entrance"
