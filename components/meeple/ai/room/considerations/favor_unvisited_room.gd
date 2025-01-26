class_name UnvisitedRoomConsideration extends RoomConsideration

func _get_room_score(meeple: Meeple, room: Room) -> float:
	return score_if_true(meeple.visited_rooms.has(room))

func _description():
	return "Favor Unvisited Rooms"
