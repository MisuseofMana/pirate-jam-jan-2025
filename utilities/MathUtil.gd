class_name MathUtil

static func decay_to_vec2(a: Vector2, b: Vector2, decay: float, deltaTime: float) -> Vector2:
	return b + (a - b) * exp(-decay * deltaTime)