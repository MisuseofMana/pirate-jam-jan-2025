@tool
class_name MacguffinStrategy extends Resource
## Decide which macguffin a meeple is interested in.

@export var considerations: Array[MacguffinConsideration] = []

func select_macguffin(meeple: Meeple, macguffins: Array[Node2D]) -> Node2D:
	return ChoiceUtil.select(meeple, macguffins, considerations)
