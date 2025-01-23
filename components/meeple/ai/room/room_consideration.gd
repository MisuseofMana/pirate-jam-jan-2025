@tool
class_name RoomConsideration extends Consideration
## Provide a score for a meeple's interest in a room.

func _get_room_score(_meeple: Meeple, _room: Room) -> float:
	return ErrorUtil.assert_abstract()

func _get_score(subject, object) -> float:
	return _get_room_score(subject, object)
