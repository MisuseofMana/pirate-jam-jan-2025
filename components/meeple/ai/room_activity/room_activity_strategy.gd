@tool
class_name RoomActivityStrategy extends Resource
## Decide which room a meeple should pursue.

@export var considerations: Array[RoomActivityConsideration] = []

func select(meeple: Meeple) -> Meeple.RoomActivity:
	return ChoiceUtil.select(meeple, Meeple.get_all_activities(), considerations)

func get_scores(meeple: Meeple) -> Array[ChoiceUtil.Score]:
	return ChoiceUtil.get_scores(meeple, Meeple.get_all_activities(), considerations)