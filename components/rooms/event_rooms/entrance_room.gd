class_name EntranceRoom extends Room

@export var spawnable_meeple: Array[PackedScene] = []

static func get_all(node_in_tree: Node) -> Array[EntranceRoom]:
	var entrances: Array[EntranceRoom] = []
	for node in node_in_tree.get_tree().get_nodes_in_group("entrance"):
		if node is EntranceRoom:
			entrances.append(node)
	return entrances

func _ready() -> void:
	add_to_group("entrance")
	super._ready()

func handle_room_click():
	click_error_sfx.play()
	
func room_is_clickable():
	return false
	
func spawn_meeple(scene: PackedScene, soul_value: int) -> void:
	var meeple := scene.instantiate() as Meeple
	meeple.soul_value = soul_value
	assert(meeple, "Scene must have a Meeple root node")
	room_sprite.add_child(meeple)
	meeple.position = get_random_walkable_local_position(meeple.compute_nav_layers())

func start_wave() -> void:
	for meeple in get_meeples():
		meeple.notify_wave_started()
