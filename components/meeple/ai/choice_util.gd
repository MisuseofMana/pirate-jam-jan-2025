class_name ChoiceUtil
## Base class for strategies. Strategies allow "contexts" (e.g. Meeple) to choose between "Choices" (e.g. Behaviors).

## Selects the best choice from a list of choices based on the context and considerations.
static func select(context, choices: Array, considerations: Array) -> Object:
	var scores := get_scores(context, choices, considerations)
	if scores.size() > 0:
		var selected = scores[0]
		return selected.object
	return null

## Returns a list of scores for each object considered, sorted by overall score.
static func get_scores(context, choices: Array, considerations: Array) -> Array[Score]:
	var score_descriptions: Array[Score] = []
	for choice in choices:
		score_descriptions.append(get_score(context, choice, considerations))
	score_descriptions.sort_custom(Score.sort_descending)
	return score_descriptions

## Returns a score for the context's interest in a given object.
static func get_score(context, object, considerations: Array) -> Score:
	var overall_score := 1.0
	var consideration_scores: Array[ConsiderationScore] = []
	for consideration in considerations:
		var consideration_score := (consideration as Consideration).get_score(context, object)
		overall_score *= consideration_score
		consideration_scores.append(ConsiderationScore.new(consideration.description(), consideration_score))
	consideration_scores.sort_custom(ConsiderationScore.sort_descending)
	return Score.new(overall_score, consideration_scores, object)

## A record describing the influence of a consideration on a choice.
class ConsiderationScore:
	var name: String
	var score: float

	static func sort_descending(a: ConsiderationScore, b: ConsiderationScore) -> bool:
		return a.score > b.score

	func _init(p_name: String, p_score: float):
		self.name = p_name
		self.score = p_score

## A summary of the overall score and consideration scores for a choice.
class Score:
	var overall_score: float
	var considerations: Array[ConsiderationScore]
	var object: Object

	static func sort_descending(a: Score, b: Score) -> bool:
		return a.overall_score > b.overall_score

	func _init(p_overall_score: float, p_considerations: Array[ConsiderationScore], p_object: Object):
		self.overall_score = p_overall_score
		self.considerations = p_considerations
		self.object = p_object

	func _to_string() -> String:
		var formatted := "Choice: " + str(self.object) + "\n"
		formatted += "Overall: " + str(self.overall_score) + "\n"
		for consideration in self.considerations:
			formatted += "  " + consideration.name + ": " + str(consideration.score) + "\n"
		return formatted
