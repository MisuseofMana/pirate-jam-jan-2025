class_name RandomRoomConsideration extends RoomConsideration

func _get_room_score(_meeple: Meeple, _room: Room) -> float:
    return randf()

func _description():
    return "Decide Randomly"