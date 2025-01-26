class_name AdjacentRoomConsideration extends RoomConsideration

func _get_room_score(meeple: Meeple, room: Room) -> float:
	return score_if_true(meeple.current_room.is_adjacent_to(room))

func _description():
	return "Favor Adjacent Rooms"
