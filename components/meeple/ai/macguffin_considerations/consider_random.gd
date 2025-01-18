class_name ConsiderRandom extends MacguffinConsideration

func _get_macguffin_score(_meeple: Meeple, _macguffin: Node2D) -> float:
	return randf()