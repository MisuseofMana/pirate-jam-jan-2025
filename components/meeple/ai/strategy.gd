class_name Strategy extends Resource

func _select(subject: Object, objects: Array) -> Object:
	var score_descriptions := _get_score_descriptions(subject, objects)
	if score_descriptions.size() > 0:
		var selected = score_descriptions[0]
		return selected.object
	return null

func _get_considerations() -> Array[Consideration]:
	assert(false, "_get_considerations() must be overridden in derived classes.")
	return []

func _get_score_descriptions(subject: Object, objects: Array) -> Array[Strategy.Score]:
	var score_descriptions: Array[Strategy.Score] = []
	for object in objects:
		score_descriptions.append(_get_score_description(subject, object))
	score_descriptions.sort_custom(Strategy.Score.sort_descending)
	return score_descriptions

func _get_score_description(subject: Object, object: Object) -> Strategy.Score:
	var overall_score := 1.0
	var consideration_scores: Array[Strategy.ConsiderationScore] = []
	for consideration in _get_considerations():
		var consideration_score := consideration.get_score(subject, object)
		overall_score *= consideration_score
		consideration_scores.append(Strategy.ConsiderationScore.new(consideration.description(), consideration_score))
	consideration_scores.sort_custom(Strategy.ConsiderationScore.sort_descending)
	return Strategy.Score.new(overall_score, consideration_scores, object)

class ConsiderationScore:
	var name: String
	var score: float

	static func sort_descending(a: ConsiderationScore, b: ConsiderationScore) -> bool:
		return a.score > b.score

	func _init(p_name: String, p_score: float):
		self.name = p_name
		self.score = p_score

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
		var formatted := "Overall: " + str(self.overall_score) + "\n"
		for consideration in self.considerations:
			formatted += "  " + consideration.name + ": " + str(consideration.score) + "\n"
		formatted += "\n"
		return formatted