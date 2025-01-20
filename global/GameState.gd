extends Node

signal souls_changed(value)

# dungeon qualities
var souls : int = 0 :
	set(value):
		souls = value
		souls_changed.emit(value)

var consumed_priests : int = 0
var escaped_looters : int = 0

var mystique : int = 0
var defilement : int = 0
