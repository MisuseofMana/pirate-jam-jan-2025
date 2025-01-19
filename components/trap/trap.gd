extends AnimatedSprite2D
class_name Trap

@export_range(0.25, 10, 0.25) var trap_cooldown : float = 0.25
@onready var area: DamageArea = $DamageArea

@onready var timer: Timer = $Timer
@onready var coll: CollisionShape2D = $DamageArea/CollisionShape2D
@onready var reset_icon: TextureProgressBar = $ResetClock

func _ready():
	timer.wait_time = trap_cooldown
	reset_icon.hide()

func trigger_trap():
		play("activate")
		timer.start()
		reset_icon.show()
		get_tree().create_tween().tween_property(reset_icon, "value", 0, trap_cooldown)
	
func reset_trap():
	frame = 0
	reset_icon.hide()
	area.enable_collision()
