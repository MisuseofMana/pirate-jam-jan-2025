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

class ScoreResult:
	var scores: Array[Score]
	var choice
	
	func _init(p_scores: Array[Score]):
		p_scores.sort_custom(Score.sort_descending)
		self.scores = p_scores
		self.choice = null if p_scores.is_empty() else p_scores[0].choice

	func is_empty() -> bool:
		return scores.size() == 0
	
	func _to_string() -> String:
		var formatted := str(choice) + ": " + str(scores[0].score) + "\n"
		for si in scores.size():
			var score := scores[si]
			var is_final_score := si == scores.size() - 1
			var score_prefix := "└─" if is_final_score else "├─"
			formatted += score_prefix + str(score.choice) + str(score.score) + "\n"
			for ci in score.considerations.size():
				var consideration := score.considerations[ci]
				var is_final_consideration := ci == score.considerations.size() - 1
				var prefix_prefix := "│ " if not is_final_score else "  "
				var prefix := "└─" if is_final_consideration else "├─"
				formatted += prefix_prefix + prefix + str(consideration) + "\n"
		return formatted

class Score:
	var score: float
	var choice
	var considerations: Array[ConsiderationScore]

	static func sort_descending(a: Score, b: Score) -> bool:
		return a.score > b.score
		
	func _init(p_choice, p_considerations: Array[ConsiderationScore]):
		p_considerations.sort_custom(ConsiderationScore.sort_descending)
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
		self.score = lerpf(1.0 - influence, 1.0, raw_score)
		self.name = p_name

	func _to_string() -> String:
		return name + ": " + str(score)
