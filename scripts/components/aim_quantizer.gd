class_name AimQuantizer
extends RefCounted

const SECTOR_COUNT: int = 8
const DIAGONAL_COMPONENT: float = 0.7071067811865476
const DIRECTIONS: Array[Vector2] = [
	Vector2.RIGHT,
	Vector2(DIAGONAL_COMPONENT, -DIAGONAL_COMPONENT),
	Vector2.UP,
	Vector2(-DIAGONAL_COMPONENT, -DIAGONAL_COMPONENT),
	Vector2.LEFT,
	Vector2(-DIAGONAL_COMPONENT, DIAGONAL_COMPONENT),
	Vector2.DOWN,
	Vector2(DIAGONAL_COMPONENT, DIAGONAL_COMPONENT),
]


## Returns the previous sector while the vector is inside the deadzone.
## At an exact boundary, iteration order and approximate-equality handling keep
## the smaller sector index. This also resolves the 7/0 boundary in favor of 0.
static func quantize(vector: Vector2, previous_sector: int, deadzone: float = 0.0) -> int:
	assert(previous_sector >= 0 and previous_sector < SECTOR_COUNT)
	if vector.length() <= maxf(deadzone, 0.0):
		return previous_sector

	var direction := vector.normalized()
	var best_sector := 0
	var best_score := direction.dot(DIRECTIONS[0])
	for sector in range(1, SECTOR_COUNT):
		var score := direction.dot(DIRECTIONS[sector])
		if score > best_score and not is_equal_approx(score, best_score):
			best_sector = sector
			best_score = score
	return best_sector


static func direction_for_sector(sector: int) -> Vector2:
	assert(sector >= 0 and sector < SECTOR_COUNT)
	return DIRECTIONS[sector]
