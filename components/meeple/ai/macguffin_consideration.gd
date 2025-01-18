class_name MacguffinConsideration extends Consideration

func _get_macguffin_score(_meeple: Meeple, _macguffin: Node2D) -> float:
	assert(false, "_get_macguffin_score() must be overridden in derived classes.")
	return 1.0

func _get_score(subject: Object, object: Object) -> float:
	var meeple := subject as Meeple
	var macguffin := object as Node2D
	return _get_macguffin_score(meeple, macguffin)