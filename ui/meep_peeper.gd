extends Node2D

@export_group("References")
@export var viewport_margin: int
@export var viewport_dodger: Control
@export var health_value_label: Label
@export var soul_value_label: Label
@export var treasure_value_label: Label
@export var name_label: Label

@onready var dodger_base_position: Vector2 = viewport_dodger.position

var _hovered_meeple: Array[Meeple] = []

var _meep: Meeple = null:
	get():
		return _meep if _meep and is_instance_valid(_meep) else null
	set(value):
		if value == _meep: return
		if _meep:
			_meep.info_changed.disconnect(_on_meep_info_changed)
		_meep = value
		if _meep:
			_meep.info_changed.connect(_on_meep_info_changed)
			show()
		else:
			hide()

		_on_meep_info_changed()

func notify_meeple_hovered(meep: Meeple) -> void:
	if not _hovered_meeple.has(meep):
		_hovered_meeple.append(meep)
		_hovered_meeple_changed()

func notify_meeple_unhovered(meeple: Meeple) -> void:
	if _hovered_meeple.has(meeple):
		_hovered_meeple.erase(meeple)
		_hovered_meeple_changed()

func _hovered_meeple_changed():
	_hovered_meeple = _hovered_meeple.filter(func(m: Meeple): return m and is_instance_valid(m))
	if not _hovered_meeple.is_empty():
		_meep = _hovered_meeple.back()
	else:
		_meep = null

func _ready() -> void:
	if not _meep:
		hide()

func _process(delta: float) -> void:
	if _meep:
		_update_position(delta)

func _on_meep_info_changed() -> void:
	_update_labels()

func _update_labels() -> void:
	if _meep:
		health_value_label.text = str(_meep.health)
		soul_value_label.text = str(_meep.soul_value)
		treasure_value_label.text = str(_meep.treasure_collected) + "/" + str(_meep.max_treasure)
		name_label.text = _meep.meeple_name
		dodger_base_position = viewport_dodger.position

func _update_position(delta: float) -> void:
	var dodger_rect := viewport_dodger.get_global_rect()
	var camera_rect := Camera2DUtil.get_current_camera_2d_rect(self)
	var allowed_rect := camera_rect.grow_individual(
		-viewport_margin - dodger_rect.size.x / 2.0,
		-viewport_margin - dodger_rect.position.y + dodger_rect.size.y,
		-viewport_margin - dodger_rect.size.x / 2.0,
		-viewport_margin - dodger_rect.position.y - dodger_rect.size.y
	)
	var target_pos := _meep.global_position.clamp(allowed_rect.position, allowed_rect.end)

	# print(
	# 	"raw_pos: ", _meep.global_position,
	# 	"target_pos: ", target_pos
	# )

	global_position = MathUtil.decay_to_vec2(global_position, target_pos, 10.0, delta)