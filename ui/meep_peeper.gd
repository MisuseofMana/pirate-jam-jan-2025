extends Node2D

@export_group("References")
@export var health_value_label: Label
@export var soul_value_label: Label
@export var treasure_value_label: Label
@export var name_label: Label

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
	hide()
	_update_labels()

func _on_meep_info_changed() -> void:
	_update_labels()

func _update_labels() -> void:
	if _meep:
		health_value_label.text = str(_meep.health)
		soul_value_label.text = str(_meep.soul_value)
		treasure_value_label.text = str(_meep.treasure_collected) + "/" + str(_meep.max_treasure)
		name_label.text = _meep.meeple_name

func _process(delta: float) -> void:
	if _meep:
		var target_pos := _meep.global_position + Vector2(0, -20)
		global_position = MathUtil.decay_to_vec2(global_position, target_pos, 10.0, delta)
