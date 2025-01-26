class_name ThoughtPeeperResources extends Resource

@export var treasure_texture: Texture2D
@export var hurt_texture: Texture2D

func get_topic_texture(topic: ThoughtPeeper.Topic) -> Texture:
    match topic:
        ThoughtPeeper.Topic.HURT:
            return hurt_texture
        ThoughtPeeper.Topic.TREASURE:
            return treasure_texture
        _:
            return null