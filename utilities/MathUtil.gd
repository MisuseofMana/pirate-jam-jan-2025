class_name MathUtil

const MAX_INT := 9223372036854775807

static func decay_to_vec2(a: Vector2, b: Vector2, decay: float, deltaTime: float) -> Vector2:
	return b + (a - b) * exp(-decay * deltaTime)