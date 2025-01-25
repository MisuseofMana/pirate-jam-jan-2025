class_name RandomMacguffinConsideration extends MacguffinConsideration

func _get_macguffin_score(_meeple: Meeple, _treasure: Node2D) -> float:
	return randf()

func _description() -> String:
	return "Decide Randomly"