class_name Room extends Area2D

@onready var tilemap: TileMapLayer = get_parent()
@onready var dungeon_sprite = $Sprite2D

var atlas_register : Dictionary = {
	"0000": 0,
	"1000": 1,
	"0100": 2,
	"0010": 3,
	"0001": 4,
	"1010": 5,
	"0101": 6,
	"1100": 7,
	"0110": 8,
	"0011": 9,
	"1001": 10,
	"1101": 11,
	"1110": 12,
	"0111": 13,
	"1011": 14,
	"1111": 15
}

func _ready():
	tilemap.changed.connect(update_room_sprite)
	update_room_sprite()
	
func update_room_sprite():
	var coords = get_coords()
		
	var possible_connections : Array[Vector2i] = [
		tilemap.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_TOP_SIDE),
		tilemap.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
		tilemap.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),
		tilemap.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	]
	
	var cardinal_neighbors_filled : Array[int] = []
	
#		checks top, right, bottom, left
	for neighbor in possible_connections:
		cardinal_neighbors_filled.append(1 if tilemap.get_cell_source_id(neighbor) >= 0 else 0)

	var atlas_decode = "".join(cardinal_neighbors_filled.map(str))
	
	dungeon_sprite.frame = atlas_register[atlas_decode]

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
