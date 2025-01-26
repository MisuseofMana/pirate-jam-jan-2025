class_name ThoughtPeeperResources extends Resource

@export_group("Textures", "texture_")
@export var texture_treasure: Texture2D
@export var texture_hurt: Texture2D
@export var texture_thinking: Texture2D
@export var texture_exit: Texture2D

func get_topic_texture(topic: ThoughtPeeper.Topic) -> Texture:
    match topic:
        ThoughtPeeper.Topic.HURT:
            return texture_hurt
        ThoughtPeeper.Topic.TREASURE:
            return texture_treasure
        ThoughtPeeper.Topic.THINKING:
            return texture_thinking
        ThoughtPeeper.Topic.EXIT:
            return texture_exit
        _:
            return ErrorUtil.assert_invalid_enum_value(topic)