extends Node

signal souls_changed(value)

# dungeon qualities
var souls : int = 10 :
	set(value):
		var oldValue = souls
		souls = value
#		reducing if oldValue is greater than new value
		var isReducing : bool = oldValue > value
		while oldValue != value:
			oldValue = oldValue - 1 if isReducing else oldValue + 1
			print(oldValue)
			souls_changed.emit(oldValue)

var consumed_priests : int = 0
var escaped_looters : int = 0

var mystique : int = 0
var defilement : int = 0
