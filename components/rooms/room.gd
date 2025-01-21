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

func get_meeples() -> Array[Meeple]:
	var meeples: Array[Meeple] = []
	for meeple in Meeple.get_all(self):
		if meeple.current_room == self:
			meeples.append(meeple)
	return meeples

func get_random_walkable_local_position() -> Vector2:
	var margin := 16
	var width := 64
	var height := 64
	return Vector2(
		-width / 2.0 + randf_range(margin, width - margin * 2),
		-height / 2.0 + randf_range(margin, height - margin * 2)
	) 

func get_random_walkable_global_position() -> Vector2:
	return global_position + get_random_walkable_local_position()
