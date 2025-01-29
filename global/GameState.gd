extends Node

signal souls_changed
signal paused
signal resumed
signal meeple_can_be_selected
signal meeple_available_to_peep
signal no_meep_to_peep

@export var souls_win_threshold: int = 99
@export var starting_souls: int = 10

# See state chart for wave frequency

@export_group("Wave 1", "wave_1_")
@export var wave_1_meeps: Array[PackedScene]
@export_range(0, 10, 1, "or_greater") var wave_1_soul_value: int = 1

@export_group("Wave 2", "wave_2_")
@export var wave_2_meeps: Array[PackedScene]
@export_range(0, 100, 1, "or_greater", "suffix:souls") var wave_2_threshold: int = 10
@export_range(0, 10, 1, "or_greater") var wave_2_soul_value: int = 5

@export_group("Wave 3", "wave_3_")
@export var wave_3_meeps: Array[PackedScene]
@export_range(0, 100, 1, "or_greater", "suffix:souls") var wave_3_threshold: int = 10
@export_range(0, 10, 1, "or_greater") var wave_3_soul_value: int = 8

@export_group("References")
@export var states: StateChart

var souls: int:
	set(value):
		if souls == value:
			return
		if value < 0 or value >= waves.size():
			current_wave_index = 0
		elif value >= waves.size():
			current_wave_index = waves.size() - 1
		else:
			current_wave_index = value
var current_wave: Wave:
	get(): return waves[current_wave_index]
var current_spawn_index: int = 0
var current_spawn: PackedScene:
	get(): return current_wave.spawns[current_spawn_index]

var meeple_list : Array[Meeple] = []:
	set(value):
		meeple_list = value
		if meeple_list.size() == 1:
			meeple_available_to_peep.emit()
		if meeple_list.size() > 1:
			meeple_can_be_selected.emit()
		if meeple_list.is_empty():
			no_meep_to_peep.emit()

# dungeon qualities
var souls: int = 1:
	set(value):
		if (value >= 99):
			you_win()
		var oldValue = souls
		souls = value
		_on_souls_changed()

#region Public Methods

func start_game():
	souls = starting_souls
	_switch_scene("res://scenes/game.tscn")
	states.send_event("game_started")

func notify_meep_drawing_sword():
	states.send_event("meep_drawing_sword")

func notify_meep_will_explode():
	states.send_event("meep_will_explode")

func notify_meep_drew_sword():
	_lose_game()

func notify_meep_exploded(meep: Meeple) -> void:
	souls -= meep.soul_value

func notify_soul_collected(soul: MeepleSoul) -> void:
	souls += soul.soul_value

# region Private Methods

func _spawn_meeple():
	var meep: PackedScene
	var soul_value: int
	if souls >= wave_3_threshold:
		meep = wave_3_meeps.pick_random()
		soul_value = wave_3_soul_value
	elif souls >= wave_2_threshold:
		meep = wave_2_meeps.pick_random()
		soul_value = wave_2_soul_value
	else:
		meep = wave_1_meeps.pick_random()
		soul_value = wave_1_soul_value

	for entrance in EntranceRoom.get_all(self):
		entrance.spawn_meeple(meep, soul_value)

func _pause():
	paused.emit()

func _resume():
	resumed.emit()

func _switch_scene(scene_path):
	_deferred_switch_scene.call_deferred(scene_path)

func _win_game():
	_switch_scene("res://scenes/win_screen.tscn")
	states.send_event("game_won")

func _lose_game():
	_switch_scene("res://scenes/lose_screen.tscn")
	states.send_event("game_lost")
	
func _deferred_switch_scene(scene_path):
	get_tree().current_scene.free()
	var packed_scene := load(scene_path) as PackedScene
	var scene = packed_scene.instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene

func _on_souls_changed():
	if souls >= souls_win_threshold:
		_win_game()

	souls_changed.emit(souls)
