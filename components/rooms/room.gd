class_name Room extends Area2D

@onready var tilemap: TileMapLayer = get_parent()

func get_coords() -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(global_position))

func is_adjacent_to(other: Room) -> bool:
	return get_coords().distance_to(other.get_coords()) == 1
