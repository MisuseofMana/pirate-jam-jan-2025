class_name TreasureRoomConsideration extends RoomConsideration

func _get_room_score(_meeple: Meeple, room: Room) -> float:
    return remap(room.get_treasure_count(), 0.0, 3.0, 0.0, 1.0)

func _description() -> String:
    return "Favor Treasure"