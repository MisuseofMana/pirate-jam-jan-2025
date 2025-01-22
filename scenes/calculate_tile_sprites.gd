extends TileMapLayer

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
		
		var neighbors_occupied : Array[bool] = []
		
#		checks top, right, bottom, left
		for neighbor in possible_connections:
			#print(get_cell_source_id(neighbor))
			print(get_cell_tile_data(neighbor))
			#neigbors_occupied.append()
			
