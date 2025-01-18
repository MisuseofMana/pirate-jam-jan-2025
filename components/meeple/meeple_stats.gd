extends Resource
class_name MeepleStats

@export_group("Meeple Stats")
@export_range(0, 1, 0.1) var greed: float = 0
@export_range(0, 1, 0.1) var piety: float = 0
@export_range(0, 4) var health = 0

@export_group("AI")
@export var macguffin_strategy: MacguffinStrategy