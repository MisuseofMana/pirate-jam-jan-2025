@tool
class_name MacguffinConsideration extends Consideration
## Provide a score for a meeple's interest in a macguffin.

func _get_macguffin_score(_meeple: Meeple, _macguffin: Node2D) -> float:
	return ErrorUtil.assert_abstract()

func _get_score(subject, object) -> float:
	return _get_macguffin_score(subject, object)