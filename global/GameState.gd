extends Node

@export var wave_state: StateChart

signal souls_changed(value)

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

var consumed_priests: int = 0
var escaped_looters: int = 0

var mystique: int = 0
var defilement: int = 0

var meeple_spawned_this_wave: int = 0
var max_meeple_per_wave: int = 2

func spawn_meeple():
	for entrance in EntranceRoom.get_all(self):
		entrance.spawn_meeple()
		meeple_spawned_this_wave += 1
	if meeple_spawned_this_wave >= max_meeple_per_wave:
		wave_state.send_event("release_wave")
	else:
		wave_state.send_event("keep_spawning")

func release_wave():
	for entrance in EntranceRoom.get_all(self):
		entrance.start_wave.call_deferred()
	meeple_spawned_this_wave = 0
