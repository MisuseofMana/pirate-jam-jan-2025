class_name MacguffinStrategy extends Resource

@export var considerations: Array[MacguffinConsideration] = []

func select_macguffin(meeple: Meeple) -> Node2D:
	var score_descriptions := get_score_descriptions(meeple)
	var selected = score_descriptions[0]
	print(selected)
	return selected.transition

func get_score_descriptions(meeple: Meeple) -> Array[ScoreDescription]:
	var possible := meeple.get_tree().get_nodes_in_group("macguffin") as Array[Node2D]
	var score_descriptions: Array[ScoreDescription] = []
	for macguffin in possible:
		score_descriptions.append(get_score_description(meeple, macguffin))
	score_descriptions.sort_custom(ScoreDescription.sort_descending)
	return score_descriptions

func get_score_description(meeple: Meeple, macguffin: Node2D) -> ScoreDescription:
	var overall_score := 1.0
	var consideration_score_descriptions: Array[ConsiderationScoreDescription] = []
	for consideration in considerations:
		var consideration_score := consideration.get_score(meeple, macguffin)
		overall_score *= consideration_score
		consideration_score_descriptions.append(ConsiderationScoreDescription.new(consideration.description(), consideration_score))
	consideration_score_descriptions.sort_custom(ConsiderationScoreDescription.sort_descending)
	return ScoreDescription.new(overall_score, consideration_score_descriptions, macguffin)

class ConsiderationScoreDescription:
	var name: String
	var score: float

	static func sort_descending(a: ConsiderationScoreDescription, b: ConsiderationScoreDescription) -> bool:
		return a.score > b.score

	func _init(p_name: String, p_score: float):
		self.name = p_name
		self.score = p_score

class ScoreDescription:
	var overall_score: float
	var considerations: Array[ConsiderationScoreDescription]
	var macguffin: Node2D

	static func sort_descending(a: ScoreDescription, b: ScoreDescription) -> bool:
		return a.overall_score > b.overall_score

	func _init(p_overall_score: float, p_considerations: Array[ConsiderationScoreDescription], p_macguffin: Node2D):
		self.overall_score = p_overall_score
		self.considerations = p_considerations
		self.macguffin = p_macguffin

	func _to_string() -> String:
		var formatted := "Overall: " + str(self.overall_score) + "\n"
		for consideration in self.considerations:
			formatted += "  " + consideration.name + ": " + str(consideration.score) + "\n"
		formatted += "\n"
		return formatted