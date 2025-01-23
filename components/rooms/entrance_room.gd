class_name EntranceRoom extends Room

@export var spawnable_meeple: Array[PackedScene] = []

static func get_all(node_in_tree: Node) -> Array[EntranceRoom]:
	var entrances: Array[EntranceRoom] = []
	for node in node_in_tree.get_tree().get_nodes_in_group("entrance"):
		if node is EntranceRoom:
			entrances.append(node)
	print(entrances)
	return entrances

func _ready() -> void:
	add_to_group("entrance")
	dungeon_controller.changed.connect(update_room_sprite)
	update_room_sprite()
	
func spawn_meeple(scene: PackedScene) -> void:
	var meeple := scene.instantiate() as Meeple
	assert(meeple, "Scene must have a Meeple root Node2D")
	add_child(meeple)
	meeple.position = get_random_walkable_local_position()

func start_wave() -> void:
	for meeple in get_meeples():
		meeple.notify_wave_started()
