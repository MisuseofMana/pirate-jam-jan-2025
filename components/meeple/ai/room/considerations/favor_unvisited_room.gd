class_name UnvisitedRoomConsideration extends RoomConsideration

func _get_room_score(meeple: Meeple, room: Room) -> float:
	return 0.0 if meeple.visited_rooms.has(room) else 1.0

func _description():
	return "Favor Unvisited Rooms"
