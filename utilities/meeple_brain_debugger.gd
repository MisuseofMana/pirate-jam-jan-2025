class_name MeepleBrainDebugger extends "res://addons/godot_state_charts/utilities/state_chart_debugger.gd"

@export_flags_2d_physics var pick_layers: int
var pick_position: Vector2
var should_pick: bool = false

func _ready() -> void:
	_attach_to_first_meeple.call_deferred()
	super._ready()
	
func _attach_to_first_meeple() -> void:
	var meeple := get_tree().get_nodes_in_group("meeple")
	if not meeple.is_empty():
		debug_node(meeple[0].brain)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_pressed():
			should_pick = true

func _physics_process(_delta: float) -> void:
	if should_pick:
		var viewport := get_viewport()
		var space := viewport.world_2d.direct_space_state
		var params := PhysicsPointQueryParameters2D.new()
		params.position = viewport.get_camera_2d().get_global_mouse_position()
		params.collision_mask = pick_layers
		params.collide_with_areas = true
		var results := space.intersect_point(params)
		for result in results:
			if result["collider"]:
				var parent = result.collider.get_parent()
				if parent is Meeple:
					debug_node(parent.brain)
		should_pick = false
