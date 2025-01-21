@tool
class_name RoomStrategy extends Resource
## Decide which room a meeple should pursue.

@export var considerations: Array[RoomConsideration] = []

func select_room(meeple: Meeple, rooms: Array[Room]) -> Room:
	return ChoiceUtil.select(meeple, rooms, considerations)

func get_room_scores(meeple: Meeple, rooms: Array[Room]) -> Array[ChoiceUtil.Score]:
	return ChoiceUtil.get_scores(meeple, rooms, considerations)