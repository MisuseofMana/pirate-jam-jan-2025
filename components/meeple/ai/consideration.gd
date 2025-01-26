@tool
class_name Consideration extends Resource
## Base class for considerations. Considerations are aspects of a decision that are taken into account when making a choice.

## An influence of 1.0 means the consideration is fully considered. An influence of 0.0 means the consideration is ignored. A value in between influences the relative importance of the consideration.
@export_range(0, 1) var influence: float = 1.0:
	set(new_value):
		influence = clamp(new_value, 0.0, 1.0)
		_update_description()

func _init() -> void:
	_update_description()

## A score of 1.0 means the choice is not penalized. A score of 0.0 means the choice will not be selected. Everything in between means the choice is suboptimal, but acceptable.
func get_score(subject, object) -> float:
	var raw_score := clampf(_get_score(subject, object), 0.0, 1.0)
	return lerp((1.0 - influence), 1.0, raw_score)

## Subclasses should override this method to provide a score for the consideration.
func _get_score(_subject, _object) -> float:
	return ErrorUtil.assert_abstract()

## A readable description of the consideration.
func description() -> String:
	return "%s (%.2f)" % [_description(), influence]

## Subclasses should override this method to provide a more specific description of the consideration.
func _description() -> String:
	return "Consideration"

func _update_description() -> void:
	resource_name = description()

## Scoring utility. As the input increases, the score increases at a diminishing rate. The midpoint is the input value at which the score is 0.5.
static func score_diminishing_returns(input: float, midpoint: float = 2.0) -> float:
	return 1.0 - pow(2, input / -midpoint)

## Scoring utility. As the input increases, the score decreases at a diminishing rate. The midpoint is the input value at which the score is 0.5.
static func score_diminishing_loss(input: float, midpoint: float = 2.0) -> float:
	return 1.0 - score_diminishing_returns(input, midpoint)

## Scoring utility. Returns 1.0 if the input is true, otherwise 0.0.
static func score_if_true(input: bool) -> float:
	return 1.0 if input else 0.0