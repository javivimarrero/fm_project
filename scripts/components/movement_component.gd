class_name MovementComponent
extends Resource

## C03 experimental tuning. One gameplay unit equals the player collider width.
@export_range(1.0, 256.0, 1.0) var pixels_per_unit: float = 24.0
@export_range(0.1, 20.0, 0.1) var max_speed_units: float = 5.0
@export_range(0.01, 1.0, 0.01) var acceleration_time: float = 0.12
@export_range(0.01, 1.0, 0.01) var braking_time: float = 0.10
@export_range(0.1, 10.0, 0.1) var jump_height_units: float = 3.0
@export_range(0.05, 2.0, 0.01) var time_to_apex: float = 0.35
@export_range(0.0, 1.0, 0.01) var coyote_time: float = 0.10
@export_range(0.0, 1.0, 0.01) var jump_buffer_time: float = 0.10
@export_range(0.0, 1.0, 0.05) var jump_release_multiplier: float = 0.50

var coyote_remaining: float = 0.0
var jump_buffer_remaining: float = 0.0


var max_speed: float:
	get: return max_speed_units * pixels_per_unit
var acceleration: float:
	get: return max_speed / acceleration_time
var braking: float:
	get: return max_speed / braking_time
var jump_height: float:
	get: return jump_height_units * pixels_per_unit
var gravity: float:
	get: return (2.0 * jump_height) / (time_to_apex * time_to_apex)
var jump_speed: float:
	get: return gravity * time_to_apex


## Advances movement state exactly once for the supplied immutable snapshot.
## Collision resolution remains the CharacterBody2D owner's responsibility.
func step_velocity(
		current_velocity: Vector2,
		snapshot: InputSnapshot,
		delta: float,
		is_grounded: bool
) -> Vector2:
	assert(delta > 0.0)
	var next_velocity := current_velocity
	var target_speed := snapshot.move_axis * max_speed
	var horizontal_rate := acceleration if not is_zero_approx(snapshot.move_axis) else braking
	next_velocity.x = move_toward(next_velocity.x, target_speed, horizontal_rate * delta)

	if is_grounded:
		coyote_remaining = coyote_time
	else:
		coyote_remaining = maxf(coyote_remaining - delta, 0.0)

	if snapshot.jump_pressed:
		jump_buffer_remaining = jump_buffer_time
	else:
		jump_buffer_remaining = maxf(jump_buffer_remaining - delta, 0.0)

	if jump_buffer_remaining > 0.0 and coyote_remaining > 0.0:
		next_velocity.y = -jump_speed
		jump_buffer_remaining = 0.0
		coyote_remaining = 0.0
	elif not is_grounded:
		next_velocity.y += gravity * delta
	elif next_velocity.y > 0.0:
		next_velocity.y = 0.0

	if snapshot.jump_released and next_velocity.y < 0.0:
		next_velocity.y *= jump_release_multiplier

	return next_velocity


func reset() -> void:
	coyote_remaining = 0.0
	jump_buffer_remaining = 0.0
