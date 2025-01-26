class_name FillPocketsConsideration extends RoomActivityConsideration

func _get_activity_score(meeple: Meeple, activity: Meeple.RoomActivity) -> float:
	match activity:
		Meeple.RoomActivity.LOOK_FOR_TREASURE:
			if meeple.current_room.get_treasure_count() > 0 and meeple.treasure_collected < meeple.max_treasure:
				return 1.0
			else:
				return 0.0
				
		_: return 0.0

func _description() -> String:
	return "Fill Pockets"
