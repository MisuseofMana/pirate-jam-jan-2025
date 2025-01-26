@tool
class_name RoomActivityConsideration extends Consideration
## Provide a score for a meeple's interest in an activity within the current room

func _get_activity_score(_meeple: Meeple, _activity: Meeple.RoomActivity) -> float:
	return ErrorUtil.assert_abstract()

func _get_score(subject, object) -> float:
	return _get_activity_score(subject, object)
