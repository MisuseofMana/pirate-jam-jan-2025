class_name MacguffinStrategy extends Strategy

@export var considerations: Array[MacguffinConsideration] = []

func select_macguffin(meeple: Meeple, macguffins: Array[Node2D]) -> Node2D:
	return _select(meeple, macguffins as Array)

func _get_considerations() -> Array[Consideration]:
	var arr: Array[Consideration] = []
	arr.assign(arr)
	return arr