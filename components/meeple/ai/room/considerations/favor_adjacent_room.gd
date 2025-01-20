class_name AdjacentRoomConsideration extends RoomConsideration

func _get_room_score(meeple: Meeple, room: Room) -> float:
    return 1.0 if meeple.current_room.is_adjacent_to(room) else 0.0

func _description():
    return "Favor Adjacent Rooms"