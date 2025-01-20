@tool
class_name RoomStrategy extends Resource
## Decide which room a meeple should pursue.

@export var considerations: Array[RoomConsideration] = []

func select_room(meeple: Meeple, rooms: Array[Room]) -> Room:
	return ChoiceUtil.select(meeple, rooms, considerations)

func get_room_scores(meeple: Meeple, rooms: Array[Room]) -> Dictionary:
	var results: Dictionary = {}
	for room in rooms:
		var score = 0.0
		for consideration in considerations:
			score += consideration.get_room_score(meeple, room)
		results[room] = score
	return results