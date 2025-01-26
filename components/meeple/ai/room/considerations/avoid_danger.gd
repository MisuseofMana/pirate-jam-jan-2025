class_name AvoidDangerRoomConsideration extends RoomConsideration

func _get_room_score(meeple: Meeple, room: Room) -> float:
	var danger := maxf(0, room.get_danger_count() - meeple.health)
	return score_diminishing_loss(danger, 2.0)

func _description():
	return "Avoid Entrance"
