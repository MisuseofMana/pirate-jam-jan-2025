@tool
class_name MacguffinStrategy extends Resource
## Decide which macguffin a meeple is interested in.

@export var considerations: Array[MacguffinConsideration] = []

func select(meeple: Meeple, treasures: Array[Treasure]) -> Treasure:
	return ChoiceUtil.select(meeple, treasures, considerations)

func get_scores(meeple: Meeple, treasures: Array[Treasure]) -> Array[ChoiceUtil.Score]:
	return ChoiceUtil.get_scores(meeple, treasures, considerations)
