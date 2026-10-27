extends SceneTree

const Movement := preload("res://scripts/components/movement_component.gd")
const Snapshot := preload("res://scripts/components/input_snapshot.gd")
const Arena := preload("res://scenes/prototypes/duel_arena.tscn")

const DELTA: float = 1.0 / 60.0

var _failures: int = 0
var _checks: int = 0
var _tick: int = 0


func _initialize() -> void:
	call_deferred(&"_run_tests")


func _run_tests() -> void:
	_test_derived_parameters()
	_test_horizontal_acceleration_and_braking()
	_test_full_and_variable_jump()
	_test_coyote_time()
	_test_jump_buffer()
	await _test_arena_collisions_and_snapshot_consumption()

	if _failures == 0:
		print("C03 TESTS PASSED: %d checks" % _checks)
		quit(0)
	else:
		printerr("C03 TESTS FAILED: %d of %d checks" % [_failures, _checks])
		quit(1)


func _test_derived_parameters() -> void:
	var movement := Movement.new()
	_expect_near(movement.max_speed, 120.0, 0.001, "5 u/s at 24 px/u")
	_expect_near(movement.acceleration, 1000.0, 0.001, "reaches maximum in 0.12 s")
	_expect_near(movement.braking, 1200.0, 0.001, "brakes in 0.10 s")
	_expect_near(movement.jump_height, 72.0, 0.001, "jump height is 3 u")
	_expect_near(movement.gravity, 1175.5102, 0.01, "gravity derived from apex contract")
	_expect_near(movement.jump_speed, 411.4286, 0.01, "jump speed derived from apex contract")


func _test_horizontal_acceleration_and_braking() -> void:
	var movement := Movement.new()
	var velocity := Vector2.ZERO
	var distance := 0.0
	for frame in range(8):
		velocity = movement.step_velocity(velocity, _snapshot(1.0), DELTA, true)
		distance += velocity.x * DELTA
	_expect_near(velocity.x, movement.max_speed, 0.001, "horizontal acceleration reaches maximum")
	_expect_true(distance > 0.0, "horizontal movement advances position")
	for frame in range(6):
		velocity = movement.step_velocity(velocity, _snapshot(0.0), DELTA, true)
	_expect_near(velocity.x, 0.0, 0.001, "horizontal braking reaches rest")


func _test_full_and_variable_jump() -> void:
	var full := _simulate_jump(-1)
	var variable := _simulate_jump(5)
	_expect_near(full.apex_time, 0.35, DELTA + 0.001, "full jump apex duration")
	_expect_near(full.apex_height, 72.0, 4.0, "full jump apex height")
	_expect_near(full.total_time, 0.70, 0.05, "full jump flight duration")
	_expect_true(variable.apex_height < full.apex_height * 0.75, "release produces a lower variable jump")
	_expect_true(variable.total_time < full.total_time, "release produces a shorter jump")


func _test_coyote_time() -> void:
	var inside := Movement.new()
	var velocity := inside.step_velocity(Vector2.ZERO, _snapshot(), DELTA, true)
	for frame in range(4):
		velocity = inside.step_velocity(velocity, _snapshot(), DELTA, false)
	velocity = inside.step_velocity(velocity, _snapshot(0.0, true, true), DELTA, false)
	_expect_true(velocity.y < 0.0, "coyote jump works inside 0.10 s")

	var outside := Movement.new()
	velocity = outside.step_velocity(Vector2.ZERO, _snapshot(), DELTA, true)
	for frame in range(8):
		velocity = outside.step_velocity(velocity, _snapshot(), DELTA, false)
	velocity = outside.step_velocity(velocity, _snapshot(0.0, true, true), DELTA, false)
	_expect_true(velocity.y >= 0.0, "coyote jump is rejected outside 0.10 s")


func _test_jump_buffer() -> void:
	var inside := Movement.new()
	var velocity := inside.step_velocity(Vector2(0.0, 100.0), _snapshot(0.0, true, true), DELTA, false)
	for frame in range(3):
		velocity = inside.step_velocity(velocity, _snapshot(), DELTA, false)
	velocity = inside.step_velocity(velocity, _snapshot(), DELTA, true)
	_expect_true(velocity.y < 0.0, "buffered jump fires on landing inside 0.10 s")

	var outside := Movement.new()
	velocity = outside.step_velocity(Vector2(0.0, 100.0), _snapshot(0.0, true, true), DELTA, false)
	for frame in range(8):
		velocity = outside.step_velocity(velocity, _snapshot(), DELTA, false)
	velocity = outside.step_velocity(velocity, _snapshot(), DELTA, true)
	_expect_true(velocity.y >= 0.0, "buffered jump expires outside 0.10 s")


func _test_arena_collisions_and_snapshot_consumption() -> void:
	var arena := Arena.instantiate()
	root.add_child(arena)
	await physics_frame
	await physics_frame
	var player: CharacterBody2D = arena.get_node("Player")
	var controller: InputController = arena.get_node("InputController")
	_expect_true(player.is_on_floor(), "player collides with arena floor")

	var count_before: int = player.consumed_snapshot_count
	var tick_before: int = player.last_consumed_tick
	await physics_frame
	_expect_eq(player.consumed_snapshot_count, count_before + 1, "one snapshot consumed per physics tick")
	_expect_eq(player.last_consumed_tick, tick_before + 1, "consumed snapshots have consecutive tick ids")
	_expect_eq(player.last_consumed_tick, controller.latest_snapshot.tick_id, "player consumes the current InputController snapshot")

	player.position.x = 40.0
	Input.action_press(&"move_left")
	for frame in range(30):
		await physics_frame
	Input.action_release(&"move_left")
	_expect_true(player.position.x >= 31.9, "left wall blocks the player")
	_expect_true(player.is_on_wall(), "left wall contact is reported")

	player.position.x = 600.0
	player.velocity = Vector2.ZERO
	Input.action_press(&"move_right")
	for frame in range(30):
		await physics_frame
	Input.action_release(&"move_right")
	_expect_true(player.position.x <= 608.1, "right wall blocks the player")
	_expect_true(player.is_on_wall(), "right wall contact is reported")
	arena.queue_free()


func _simulate_jump(release_frame: int) -> Dictionary:
	var movement := Movement.new()
	var velocity := movement.step_velocity(Vector2.ZERO, _snapshot(0.0, true, true), DELTA, true)
	var position_y := 0.0
	var apex_height := 0.0
	var apex_time := 0.0
	var total_time := 0.0
	for frame in range(180):
		var released := frame == release_frame
		velocity = movement.step_velocity(velocity, _snapshot(0.0, false, not released, released), DELTA, false)
		position_y += velocity.y * DELTA
		total_time += DELTA
		if -position_y > apex_height:
			apex_height = -position_y
			apex_time = total_time
		if position_y >= 0.0 and velocity.y > 0.0:
			break
	return {&"apex_height": apex_height, &"apex_time": apex_time, &"total_time": total_time}


func _snapshot(move_axis: float = 0.0, jump_pressed: bool = false, jump_held: bool = false, jump_released: bool = false) -> InputSnapshot:
	_tick += 1
	var jump_state := {&"pressed": jump_pressed, &"held": jump_held, &"released": jump_released}
	var neutral := {&"pressed": false, &"held": false, &"released": false}
	return Snapshot.new(_tick, move_axis, Vector2.RIGHT, 0, jump_state, neutral, neutral, neutral, neutral)


func _expect_eq(actual: Variant, expected: Variant, label: String) -> void:
	_checks += 1
	if actual != expected:
		_failures += 1
		printerr("FAIL %s: expected %s, got %s" % [label, expected, actual])


func _expect_near(actual: float, expected: float, tolerance: float, label: String) -> void:
	_checks += 1
	if absf(actual - expected) > tolerance:
		_failures += 1
		printerr("FAIL %s: expected %f ± %f, got %f" % [label, expected, tolerance, actual])


func _expect_true(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures += 1
		printerr("FAIL %s" % label)
