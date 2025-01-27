class_name SwordRoom extends Room

signal sword_interacted_with(meeple_node : Meeple)

func initate_sword_event(meeple_interacting : Meeple):
	sword_interacted_with.emit(meeple_interacting)
