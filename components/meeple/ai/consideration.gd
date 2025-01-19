@tool
class_name Consideration extends Resource

## An influence of 1.0 means the consideration is fully considered. An influence of 0.0 means the consideration is ignored. A value in between influences the relative importance of the consideration.
@export_range(0, 1) var influence: float = 1.0:
	set(new_value):
		influence = clamp(new_value, 0.0, 1.0)
		_update_description()

func _init() -> void:
	_update_description()

## A score of 1.0 means the action is not penalized. A score of 0.0 means the choice will not be selected. Everything in between means the action is suboptimal, but acceptable.
func get_score(subject, object) -> float:
	var raw_score := clampf(_get_score(subject, object), 0.0, 1.0)
	return lerp((1.0 - influence), 1.0, raw_score)
	
func _get_score(_subject, _object) -> float:
	assert(false, "_get_score() must be overridden in derived classes.")
	return 1.0

func description() -> String:
	return "%s (%.2f)" % [_description(), influence]

func _description() -> String:
	return "Consideration"

func _update_description() -> void:
	resource_name = description()