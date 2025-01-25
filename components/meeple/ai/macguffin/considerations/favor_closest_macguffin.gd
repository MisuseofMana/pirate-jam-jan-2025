class_name FavorClosestMacguffinConsideration extends MacguffinConsideration

func _get_macguffin_score(meeple: Meeple, treasure: Treasure) -> float:
	var raw_distance := meeple.global_position.distance_to(treasure.global_position)
	var score := remap(raw_distance, 20, 300.0, 1.0, 0.0)
	return score

func _description() -> String:
	return "Prefer Closest"
