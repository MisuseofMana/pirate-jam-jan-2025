class_name MeepPeeperParchment extends Control

@export_group("Internal")
@export var health_value_label: Label
@export var soul_value_label: Label
@export var treasure_value_label: Label
@export var name_label: Label
@export var meep_portrait : TextureRect
@export var animation_player : AnimationPlayer
@export var meep_readout : VBoxContainer
@export var no_meep_message : Label
@export var space_hint : Label

@export_group("References")
@export var dungeon_tiles : DungeonRoomController

var no_alpha : Color = Color(1, 1, 1, 0)
var full_alpha : Color = Color(1, 1, 1, 1)

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
			_update_labels()
			_meep.info_changed.connect(_on_meep_info_changed)
			_meep.meep_died.connect(_remove_selected_meep)

		_update_labels()

func _ready():
	GameState.meeple_available_to_peep.connect(auto_select_meep)
	GameState.select_new_available_meep.connect(select_new_meep)
	
func _on_meep_info_changed() -> void:
	_update_labels()

func _update_labels() -> void:
	if _meep:
		health_value_label.text = str(_meep.health)
		soul_value_label.text = str(_meep.soul_value)
		treasure_value_label.text = str(_meep.treasure_collected) + " / " + str(_meep.max_treasure)
		name_label.text = _meep.meeple_name
		meep_portrait.texture = _meep.portrait
		meep_portrait.modulate = _meep.tint
	
func auto_select_meep():
	select_new_meep()

func select_new_meep():
	if GameState.meeple_list.size() > 0:
		_meep = GameState.meeple_list.back()
		if meep_readout.modulate == no_alpha:
			animation_player.play("fade_in_peeper")
	else:
		_meep = null
		if meep_readout.modulate == full_alpha:
			animation_player.play("fade_out_peeper")

func _remove_selected_meep():
	_meep = null
	get_new_target_meep()
	
func get_new_target_meep():
	if GameState.meeple_list.size() == 0:
		_meep = null
	elif GameState.meeple_list.size() > 1:
		var displayed_meep_index = GameState.meeple_list.find(_meep)
		if displayed_meep_index == -1:
			if GameState.meeple_list.back():
				_meep = GameState.meeple_list.back()
		else:
			var next_meep_index = displayed_meep_index + 1
			var meep_list_max_index = GameState.meeple_list.size() - 1
			if next_meep_index > meep_list_max_index:
				next_meep_index = 0
			if is_instance_valid(GameState.meeple_list[next_meep_index]):
				_meep = GameState.meeple_list[next_meep_index]

func _process(_delta):
	if Input.is_action_just_pressed("swap_meep"):
		get_new_target_meep()

func on_parchment_click(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_new_target_meep()
