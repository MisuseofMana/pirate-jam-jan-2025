class_name RoomActivityStrategy extends Strategy
## Decide which macguffin a meeple is interested in.

@export_group("Considerations", "consideration_")
@export_range(0.0, 1.0, 0.01) var consideration_fill_pockets: float
@export_range(0.0, 1.0, 0.01) var consideration_avoid_loafing: float
@export_range(0.0, 1.0, 0.01) var consideration_decide_randomly: float

func select(meeple: Meeple) -> Meeple.RoomActivity:
	return get_result(meeple).choice
	
func get_result(meeple: Meeple) -> ScoreResult:
	var scores: Array[Score] = []
	for activity in Meeple.get_all_activities():
		scores.append(
			Score.new(activity, [
				ConsiderationScore.new("Fill Pockets", _score_fill_pockets(meeple, activity), consideration_fill_pockets),
				ConsiderationScore.new("Avoid Loafing", _score_avoid_loafing_around(activity), consideration_avoid_loafing),
				ConsiderationScore.new("Decide Randomly", _score_randomly(), consideration_decide_randomly),
			])
		)
	return ScoreResult.new(scores)

# region Considerations

func _score_fill_pockets(meeple: Meeple, activity: Meeple.RoomActivity) -> float:
	return score_if(
		meeple.current_room.get_treasure_count() > 0 \
		and meeple.treasure_collected < meeple.max_treasure \
		and activity == Meeple.RoomActivity.TAKE_TREASURE
	)

func _score_avoid_loafing_around(activity: Meeple.RoomActivity) -> float:
	return score_if(activity != Meeple.RoomActivity.LOAF_AROUND)
