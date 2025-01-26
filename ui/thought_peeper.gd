class_name ThoughtPeeper extends Panel

@export var resources: ThoughtPeeperResources
@export var animations: AnimationPlayer
@export var texture_rect: TextureRect

enum Topic {
	HURT,
	TREASURE,
	THINKING,
	EXIT
}

func _ready() -> void:
	hide()

func appear(topic: Topic) -> void:
	texture_rect.texture = resources.get_topic_texture(topic)
	animations.play("show")