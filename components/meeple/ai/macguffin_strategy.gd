class_name MacguffinStrategy extends Strategy
## Decide which macguffin a meeple is interested in.

@export_group("Considerations", "consideration_")
@export_range(0.0, 1.0, 0.01) var consideration_favor_closest: float
@export_range(0.0, 1.0, 0.01) var consideration_decide_randomly: float

func select(meeple: Meeple, treasures: Array[Treasure]) -> Treasure:
	return get_scores(meeple, treasures)[0].choice
	
func get_scores(meeple: Meeple, treasures: Array[Treasure]) -> Array[Score]:
	var scores: Array[Score] = []
	for treasure in treasures:
		scores.append(
			Score.new(treasure, [
				ConsiderationScore.new("Favor Closest", _score_favor_closest(meeple, treasure), consideration_favor_closest),
				ConsiderationScore.new("Decide Randomly", _score_randomly(meeple, treasure), consideration_decide_randomly),
			])
		)
	return scores

# region Considerations

func _score_favor_closest(meeple: Meeple, treasure: Treasure) -> float:
	var raw_distance := meeple.global_position.distance_to(treasure.global_position)
	var score := remap(raw_distance, 20, 300.0, 1.0, 0.0)
	return score

func _score_randomly(_meeple: Meeple, _treasure: Treasure) -> float:
	return randf()
