class_name MacguffinStrategy extends Strategy
## Decide which macguffin a meeple is interested in.

@export_group("Considerations", "consideration_")
@export_range(0.0, 1.0, 0.01) var consideration_favor_closest: float
@export_range(0.0, 1.0, 0.01) var consideration_decide_randomly: float

func select(meeple: Meeple, treasures: Array[Node2D]) -> Node2D:
	return get_result(meeple, treasures).choice
	
func get_result(meeple: Meeple, treasures: Array[Node2D]) -> ScoreResult:
	var scores: Array[Score] = []
	for treasure in treasures:
		scores.append(
			Score.new(treasure, [
				ConsiderationScore.new("Favor Closest", _score_favor_closest(meeple, treasure), consideration_favor_closest),
				ConsiderationScore.new("Decide Randomly", _score_randomly(), consideration_decide_randomly),
			])
		)
	return ScoreResult.new(scores)

# region Considerations

func _score_favor_closest(meeple: Meeple, treasure: Node2D) -> float:
	var raw_distance := meeple.global_position.distance_to(treasure.global_position)
	var score := remap(raw_distance, 20, 300.0, 1.0, 0.0)
	return score
