extends Node

signal souls_changed(value)

# Wave frequency is managed in the state chart for now.

@export var waves: Array[Wave] = []

@export_group("References")
@export var wave_state: StateChart

var current_wave_index: int = 0
var current_wave: Wave:
	get(): return waves[current_wave_index]
var current_spawn_index: int = 0
var current_spawn: PackedScene:
	get(): return current_wave.spawns[current_spawn_index]

# dungeon qualities
var souls: int = 10:
	set(value):
		var oldValue = souls
		souls = value
#		reducing if oldValue is greater than new value
		var isReducing: bool = oldValue > value
		while oldValue != value:
			oldValue = oldValue - 1 if isReducing else oldValue + 1
			souls_changed.emit(oldValue)

func spawn_meeple():
	for entrance in EntranceRoom.get_all(self):
		entrance.spawn_meeple(current_spawn)
		current_spawn_index += 1
	if current_spawn_index >= current_wave.spawns.size():
		wave_state.send_event("release_wave")
	else:
		wave_state.send_event("keep_spawning")

func release_wave():
	for entrance in EntranceRoom.get_all(self):
		entrance.start_wave.call_deferred()
	current_spawn_index = 0
	current_wave_index += 1
