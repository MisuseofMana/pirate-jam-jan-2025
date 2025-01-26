class_name RandomRoomActivityConsideration extends RoomActivityConsideration

func _get_activity_score(_meeple: Meeple, _activity: Meeple.RoomActivity) -> float:
	return randf()

func _description():
	return "Decide Randomly"
