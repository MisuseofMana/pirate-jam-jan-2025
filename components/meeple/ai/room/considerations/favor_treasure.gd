class_name TreasureRoomConsideration extends RoomConsideration

func _get_room_score(meeple: Meeple, room: Room) -> float:
	var treasure_needed = meeple.max_treasure - meeple.treasure_collected
	return score_diminishing_returns(room.get_treasure_count(), 2.0 * treasure_needed)

func _description() -> String:
	return "Favor Treasure"
