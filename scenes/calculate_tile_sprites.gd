extends TileMapLayer

var atlas_register : Dictionary = {
	"0000": Vector2i(0,0),
	"0001": Vector2i(0,1),
	"0010": Vector2i(3,0),
	"0100": Vector2i(2,0),
	"1000": Vector2i(1,0),
	"1010": Vector2i(1,1),
	"0101": Vector2i(2,1),
	"1100": Vector2i(3,1),
	"0110": Vector2i(0,2),
	"0011": Vector2i(1,2),
	"1001": Vector2i(2,2),
	"0111": Vector2i(1,3),
	"1101": Vector2i(3,2),
	"1110": Vector2i(0,3),
	"1011": Vector2i(2,3),
	"1111": Vector2i(3,3)
}

func _ready():
	reskin_tiles()

func reskin_tiles():
	for cell : Vector2i in get_used_cells():
	
		var possible_connections : Array[Vector2i] = [
			get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_SIDE),
			get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
			get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),
			get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
		]
		
		var cardinal_neighbors_filled : Array[int] = []
		
#		checks top, right, bottom, left
		for neighbor in possible_connections:
			cardinal_neighbors_filled.append(1 if get_cell_alternative_tile(neighbor) >= 0 else 0)

		var atlas_decode = "".join(cardinal_neighbors_filled.map(str))
			
		set_cell(cell, 0, atlas_register[atlas_decode])
		
		
