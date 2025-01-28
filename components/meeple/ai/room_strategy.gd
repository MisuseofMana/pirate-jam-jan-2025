class_name RoomStrategy extends Strategy
## Decide which macguffin a meeple is interested in.

@export_group("Considerations", "consideration_")
@export_range(0.0, 1.0, 0.01) var consideration_avoid_danger: float
@export_range(0.0, 1.0, 0.01) var consideration_avoid_crowds: float
@export_range(0.0, 1.0, 0.01) var consideration_favor_adjacent: float
@export_range(0.0, 1.0, 0.01) var consideration_favor_treasure_count: float
@export_range(0.0, 1.0, 0.01) var consideration_favor_unvisited: float
@export_range(0.0, 1.0, 0.01) var consideration_decide_randomly: float

func select(meeple: Meeple, rooms: Array[Room]) -> Room:
	return get_result(meeple, rooms).choice
	
func get_result(meeple: Meeple, rooms: Array[Room]) -> ScoreResult:
	var scores: Array[Score] = []
	for room in rooms:
		scores.append(
			Score.new(room, [
				ConsiderationScore.new("Avoid Danger", _score_avoid_danger(meeple, room), consideration_avoid_danger),
				ConsiderationScore.new("Avoid Crowds", _score_avoid_crowds(room), consideration_avoid_crowds),
				ConsiderationScore.new("Favor Adjacent", _score_favor_adjacent(meeple, room), consideration_favor_adjacent),
				ConsiderationScore.new("Favor Treasure Count", _score_favor_treasure_count(meeple, room), consideration_favor_treasure_count),
				ConsiderationScore.new("Favor Unvisited", _score_favor_unvisited(meeple, room), consideration_favor_unvisited),
				ConsiderationScore.new("Decide Randomly", _score_randomly(), consideration_decide_randomly),
			])
		)
	return ScoreResult.new(scores)

# region Considerations

func _score_avoid_danger(meeple: Meeple, room: Room) -> float:
	var danger := maxf(0, room.get_danger_count() - meeple.health)
	return score_diminishing_loss(danger, 2.0)

func _score_avoid_crowds(room: Room) -> float:
	return score_diminishing_loss(room.get_meeple_count(), 4.0)

func _score_favor_adjacent(meeple: Meeple, room: Room) -> float:
	return score_if(meeple.current_room.is_adjacent_to(room))

func _score_favor_treasure_count(meeple: Meeple, room: Room) -> float:
	var treasure_needed = meeple.max_treasure - meeple.treasure_collected
	return score_diminishing_returns(room.get_treasure_count(), 2.0 * treasure_needed)

func _score_favor_unvisited(meeple: Meeple, room: Room) -> float:
	return score_if(not meeple.visited_rooms.has(room))
