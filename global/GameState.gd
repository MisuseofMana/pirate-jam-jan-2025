extends Node

signal souls_changed(value: int)
signal paused
signal resumed

# Wave frequency is managed in the states chart for now.

@export var waves: Array[Wave] = []

@export_group("References")
@export var states: StateChart

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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_camera"):
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

func notify_meep_exploded(meep: Meeple):
	meep.explode()
	states.send_event("meep_exploded")
	
func notify_you_win():
	states.send_event("you_win")

func lose_game():
#	show lose screen
	pass
	
func win_game():
#	show win screen
	pass

func pause():
	paused.emit()

func resume():
	resumed.emit()
