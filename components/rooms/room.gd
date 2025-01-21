class_name Room extends Area2D

@onready var tilemap: TileMapLayer = get_parent()

func get_coords() -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(global_position))

func is_adjacent_to(other: Room) -> bool:
	return get_coords().distance_to(other.get_coords()) == 1

func get_treasure_count() -> int:
	var count: int = 0
	for child in get_children():
		if child is Treasure:
			count += 1
	return count

func get_danger_count() -> int:
	var count: int = 0
	for child in get_children():
		if child is Trap:
			count += 1
	return count