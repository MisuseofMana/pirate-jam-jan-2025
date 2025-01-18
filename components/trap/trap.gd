extends AnimatedSprite2D
class_name Trap

@onready var timer: Timer = $Timer
@export_range(0.25, 10, 0.25) var trap_cooldown : float = 0.25
@onready var coll: CollisionShape2D = $DamageArea/CollisionShape2D

func _ready():
	timer.wait_time = trap_cooldown

func trigger_trap():
	if frame != 1:
		frame = 1
		timer.start()
	
func reset_trap():
	frame = 0
	coll.disabled = false
