@tool
class_name MacguffinConsideration extends Resource

## An influence of 1.0 means the consideration is fully considered. An influence of 0.0 means the consideration is ignored. A value in between influences the relative importance of the consideration.
@export_range(0, 1) var influence: float = 1.0:
	set(new_value):
		influence = clamp(new_value, 0.0, 1.0)
		_update_description()

func _init() -> void:
	_update_description()

## A score of 1.0 means the action is not penalized. A score of 0.0 means the action will not be selected. Everything in between means the action is suboptimal, but acceptable.
func get_score(meeple: Meeple, macguffin: Node2D) -> float:
	var raw_score := _get_score(meeple, macguffin)
	return lerp((1.0 - influence), 1.0, raw_score)
	
func _get_score(_meeple: Meeple, _macguffin: Node2D) -> float:
	return 1.0

func description() -> String:
	return "%s (%.2f)" % [_description(), influence]

func _description() -> String:
	return "Base Consideration"

func _update_description() -> void:
	resource_name = description()