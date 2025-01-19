class_name ConsiderDistance extends MacguffinConsideration

func _get_macguffin_score(meeple: Meeple, macguffin: Node2D) -> float:
	var raw_distance := meeple.global_position.distance_to(macguffin.global_position)
	var score := remap(raw_distance, 20, 300.0, 1.0, 0.0)
	return score

func _description() -> String:
	return "Prefer Closest"