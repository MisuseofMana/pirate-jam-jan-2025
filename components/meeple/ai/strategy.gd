class_name Strategy extends Resource

## Scoring utility. As the input increases, the score increases at a diminishing rate. The midpoint is the input value at which the score is 0.5.
static func score_diminishing_returns(input: float, midpoint: float = 2.0) -> float:
	return 1.0 - pow(2, input / -midpoint)

## Scoring utility. As the input increases, the score decreases at a diminishing rate. The midpoint is the input value at which the score is 0.5.
static func score_diminishing_loss(input: float, midpoint: float = 2.0) -> float:
	return 1.0 - score_diminishing_returns(input, midpoint)

## Scoring utility. Returns 1.0 if the input is true, otherwise 0.0.
static func score_if_true(input: bool) -> float:
	return 1.0 if input else 0.0

class Score:
	var score: float
	var choice
	var considerations: Array[ConsiderationScore]

	static func sort_descending(a: Score, b: Score) -> bool:
		return a.score > b.score
		
	func _init(p_choice, p_considerations: Array[ConsiderationScore]):
		self.considerations = p_considerations
		self.choice = p_choice
		self.score = 1.0
		for consideration in p_considerations:
			self.score *= consideration.score

	func _to_string() -> String:
		var formatted := ""
		formatted += str(choice) + ": " + str(score)
		for i in considerations.size():
			var consideration := considerations[i]
			var tree_prefix := "├─" if i < considerations.size() - 1 else "└─"
			formatted += "\n" + tree_prefix + str(consideration)
		return formatted

class ConsiderationScore:
	var score: float
	var name: String

	static func sort_descending(a: ConsiderationScore, b: ConsiderationScore) -> bool:
		return a.score > b.score

	func _init(p_name: String, raw_score: float, influence: float):
		self.score = lerpf(influence, 1.0, raw_score)
		self.name = p_name

	func _to_string() -> String:
		return name + ": " + str(score)