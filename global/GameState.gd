extends Node

signal souls_changed(value: int)
signal paused
signal resumed

# Wave frequency is managed in the states chart for now.

@export var waves: Array[Wave] = []

@export_group("References")
@export var states: StateChart

var current_wave_index: int = 0:
	set(value):
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

# dungeon qualities
var souls: int = 3:
	set(value):
		if (value >= 99):
			you_win()
		var oldValue = souls
		souls = value
#		reducing if oldValue is greater than new value
		var isReducing: bool = oldValue > value
		while oldValue != value:
			oldValue = oldValue - 1 if isReducing else oldValue + 1
			souls_changed.emit(oldValue)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_camera"):
		resume()

func start_game():
	souls = 3
#	could generate a new random dungeon here or buld a variety out as scenes to pull from
	SceneSwitcher.switch_scene("res://scenes/game.tscn")
	resume()

func spawn_meeple():
	for entrance in EntranceRoom.get_all(self):
		entrance.spawn_meeple(current_spawn)
		current_spawn_index += 1
	if current_spawn_index >= current_wave.spawns.size():
		states.send_event("release_wave")
	else:
		states.send_event("keep_spawning")

func release_wave():
	for entrance in EntranceRoom.get_all(self):
		entrance.start_wave.call_deferred()
	current_spawn_index = 0
	current_wave_index += 1

func notify_meep_drawing_sword():
	states.send_event("meep_drawing_sword")

func notify_meep_exploded():
	states.send_event("meep_exploded")

func you_win():
	SceneSwitcher.switch_scene("res://scenes/win_screen.tscn")

func pause():
	paused.emit()

func resume():
	resumed.emit()
