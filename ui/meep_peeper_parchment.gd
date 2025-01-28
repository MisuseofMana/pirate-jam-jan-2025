class_name MeepPeeperParchment extends Control

@export_group("Internal")
@export var health_value_label: Label
@export var soul_value_label: Label
@export var treasure_value_label: Label
@export var name_label: Label
@export var animation_player : AnimationPlayer
@export var meep_readout : HBoxContainer
@export var hint : Label

@export_group("References")
@export var dungeon_tiles : DungeonRoomController

func get_living_meeple() -> Array[Meeple]:
	var allMeeple : Array[Meeple] = []
	for meep in dungeon_tiles.get_tree().get_nodes_in_group("meeple"):
		if is_instance_valid(meep):
			allMeeple.append(meep)
	return allMeeple

var _meep: Meeple = null:
	get():
		return _meep if _meep and is_instance_valid(_meep) else null
	set(value):
		if value == _meep: return
		if _meep:
			_meep.is_active_meep = false
			_meep.info_changed.disconnect(_on_meep_info_changed)
			_meep.meep_died.disconnect(_remove_selected_meep)
		_meep = value
		if _meep:
			_meep.is_active_meep = true
			_meep.info_changed.connect(_on_meep_info_changed)
			_meep.meep_died.connect(_remove_selected_meep)

		_on_meep_info_changed()
	
func _on_meep_info_changed() -> void:
	_update_labels()

func _update_labels() -> void:
	if _meep:
		health_value_label.text = str(_meep.health)
		soul_value_label.text = str(_meep.soul_value)
		treasure_value_label.text = str(_meep.treasure_collected) + " / " + str(_meep.max_treasure)
		name_label.text = _meep.meeple_name

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'fade_out':
		if _meep and is_instance_valid(_meep):
			_update_labels()
			meep_readout.show()
			hint.hide()
			animation_player.play("fade_in")
		else:
			_meep = null
			meep_readout.hide()
			hint.show()
			animation_player.play("fade_in")

func _remove_selected_meep():
	_meep = null
	_toggle_parchment_message()
		
func _toggle_parchment_message():
	animation_player.play("fade_out")

func get_active_meeple_index() -> int:
	return get_living_meeple().find(_meep)

func _on_prev_meep_button_pressed():
	var active_meep_index = get_active_meeple_index()
	var living_meeple = get_living_meeple()
	if living_meeple.is_empty():
		_meep = null
		return
	if living_meeple.has(_meep):
		if living_meeple.size() - 1 > active_meep_index:
			_meep = get_living_meeple()[active_meep_index + 1]
	else:
		_meep = get_living_meeple().back()
	_toggle_parchment_message()
	

func _on_next_meep_button_pressed():
	var active_meep_index = get_active_meeple_index()
	var living_meeple = get_living_meeple()
	if living_meeple.is_empty():
		_meep = null
		return
	if living_meeple.has(_meep):
		if active_meep_index < living_meeple.size() - 1:
			_meep = get_living_meeple()[active_meep_index + 1]
	else:
		_meep = get_living_meeple().front()
	_toggle_parchment_message()
