class_name EntranceRoom extends Room

@export var spawnable_meeple: Array[PackedScene] = []

func _ready() -> void:
	add_to_group("entrance_room")
	dungeon_controller.changed.connect(update_room_sprite)
	update_room_sprite()
	
static func get_all(node_in_tree: Node) -> Array[EntranceRoom]:
	var entrances: Array[EntranceRoom] = []
	for child in node_in_tree.get_tree().get_nodes_in_group("entrance"):
		if child is EntranceRoom:
			entrances.append(child)
	return entrances

func spawn_meeple() -> void:
	var scene = spawnable_meeple.pick_random()
	var meeple := scene.instantiate() as Meeple
	assert(meeple, "Scene must have a Meeple root Node2D")
	add_child(meeple)
	meeple.position = get_random_walkable_local_position()

func start_wave() -> void:
	for meeple in get_meeples():
		meeple.notify_wave_started()
