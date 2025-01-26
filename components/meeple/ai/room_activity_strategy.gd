class_name RoomActivityStrategy extends Strategy
## Decide which macguffin a meeple is interested in.

@export_group("Considerations", "consideration_")
@export_range(0.0, 1.0, 0.01) var consideration_fill_pockets: float
@export_range(0.0, 1.0, 0.01) var consideration_decide_randomly: float

func select(meeple: Meeple) -> Meeple.RoomActivity:
	return get_scores(meeple)[0].choice
	
func get_scores(meeple: Meeple) -> Array[Score]:
	var scores: Array[Score] = []
	for activity in Meeple.get_all_activities():
		scores.append(
			Score.new(activity, [
				ConsiderationScore.new("Fill Pockets", _score_fill_pockets(meeple, activity), consideration_fill_pockets),
				ConsiderationScore.new("Decide Randomly", _score_randomly(meeple, activity), consideration_decide_randomly),
			])
		)
	return scores

# region Considerations

func _score_fill_pockets(meeple: Meeple, activity: Meeple.RoomActivity) -> float:
	match activity:
		Meeple.RoomActivity.LOOK_FOR_TREASURE:
			return score_if_true(meeple.current_room.get_treasure_count() > 0 and meeple.treasure_collected < meeple.max_treasure)
				
		_: return 0.0

func _score_randomly(_meeple: Meeple, _activity: Meeple.RoomActivity) -> float:
	return randf()
