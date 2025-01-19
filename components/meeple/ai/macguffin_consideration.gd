@tool
class_name MacguffinConsideration extends Consideration

func _get_macguffin_score(_meeple: Meeple, _macguffin: Node2D) -> float:
	assert(false, "_get_macguffin_score() must be overridden in derived classes.")
	return 1.0

func _get_score(subject, object) -> float:
	return _get_macguffin_score(subject, object)