extends SceneTree

const Quantizer := preload("res://scripts/components/aim_quantizer.gd")
const Controller := preload("res://scripts/components/input_controller.gd")

var _failures: int = 0
var _checks: int = 0


func _initialize() -> void:
	call_deferred(&"_run_tests")


func _run_tests() -> void:
	_test_eight_directions()
	_test_boundaries_and_ties()
	_test_zero_deadzone_and_normalization()
	_test_equivalent_inputs()
	_test_input_map()
	_test_snapshots_and_button_transitions()
	_test_brief_press_between_ticks()
	_test_device_transition()
	_test_rapid_device_alternation()

	if _failures == 0:
		print("C02 TESTS PASSED: %d checks" % _checks)
		quit(0)
	else:
		printerr("C02 TESTS FAILED: %d of %d checks" % [_failures, _checks])
		quit(1)


func _test_eight_directions() -> void:
	for sector in range(8):
		_expect_eq(Quantizer.quantize(Quantizer.DIRECTIONS[sector], 0), sector, "sector %d" % sector)


func _test_boundaries_and_ties() -> void:
	for sector in range(7):
		var boundary: Vector2 = (Quantizer.DIRECTIONS[sector] + Quantizer.DIRECTIONS[sector + 1]).normalized()
		_expect_eq(Quantizer.quantize(boundary, 4), sector, "boundary %d/%d selects lower" % [sector, sector + 1])
	var wrap_boundary: Vector2 = (Quantizer.DIRECTIONS[7] + Quantizer.DIRECTIONS[0]).normalized()
	_expect_eq(Quantizer.quantize(wrap_boundary, 4), 0, "boundary 7/0 selects lower index 0")


func _test_zero_deadzone_and_normalization() -> void:
	_expect_eq(Quantizer.quantize(Vector2.ZERO, 5), 5, "zero preserves previous")
	_expect_eq(Quantizer.quantize(Vector2(0.1, 0.0), 3, 0.20), 3, "deadzone preserves previous")
	_expect_eq(Quantizer.quantize(Vector2(100.0, 0.0), 4), 0, "magnitude does not affect sector")
	for sector in range(8):
		_expect_true(is_equal_approx(Quantizer.direction_for_sector(sector).length(), 1.0), "sector direction normalized %d" % sector)


func _test_equivalent_inputs() -> void:
	_expect_eq(Quantizer.quantize(Vector2(1.0, -1.0), 0), Quantizer.quantize(Vector2(0.5, -0.5), 7), "equivalent diagonals")
	_expect_eq(Quantizer.quantize(Vector2.LEFT * 0.5, 0), Quantizer.quantize(Vector2.LEFT * 4.0, 0), "equivalent left vectors")


func _test_input_map() -> void:
	for action in [&"move_left", &"move_right", &"jump", &"dodge", &"shoot", &"reload", &"lock_target", &"aim_left", &"aim_right", &"aim_up", &"aim_down"]:
		_expect_true(InputMap.has_action(action), "input action exists: %s" % action)
		_expect_true(not InputMap.action_get_events(action).is_empty(), "input action has events: %s" % action)


func _test_snapshots_and_button_transitions() -> void:
	var controller := Controller.new()
	root.add_child(controller)
	controller.mouse_aim_origin = root.get_viewport().get_mouse_position()

	Input.action_release(&"jump")
	var neutral = controller.capture_snapshot()
	_expect_true(not neutral.jump_pressed and not neutral.jump_held and not neutral.jump_released, "neutral button state")

	Input.action_press(&"jump")
	var pressed = controller.capture_snapshot()
	_expect_true(pressed.jump_pressed and pressed.jump_held and not pressed.jump_released, "pressed and held state")

	var held = controller.capture_snapshot()
	_expect_true(not held.jump_pressed and held.jump_held and not held.jump_released, "held state on consecutive snapshot")

	Input.action_release(&"jump")
	var released = controller.capture_snapshot()
	_expect_true(not released.jump_pressed and not released.jump_held and released.jump_released, "released state")
	_expect_eq(pressed.tick_id + 1, held.tick_id, "consecutive tick ids")
	_expect_true(pressed.jump_pressed and pressed.jump_held, "older snapshot remains unchanged")
	_expect_true(pressed != held and held != released, "snapshots are independent instances")
	controller.queue_free()


func _test_brief_press_between_ticks() -> void:
	var controller := Controller.new()
	root.add_child(controller)
	controller.mouse_aim_origin = root.get_viewport().get_mouse_position()
	Input.action_release(&"jump")
	controller.capture_snapshot()

	_send_action_event(controller, &"jump", true)
	_send_action_event(controller, &"jump", false)
	var brief = controller.capture_snapshot()
	_expect_true(brief.jump_pressed, "V01 brief press is preserved")
	_expect_true(brief.jump_released, "V01 brief release is preserved")
	_expect_true(not brief.jump_held, "V01 final held state is released")

	var consumed = controller.capture_snapshot()
	_expect_true(not consumed.jump_pressed and not consumed.jump_released, "V01 transition is consumed once")

	_send_action_event(controller, &"jump", true)
	_send_action_event(controller, &"jump", false)
	_send_action_event(controller, &"jump", true)
	_send_action_event(controller, &"jump", true)
	var multiple = controller.capture_snapshot()
	_expect_true(multiple.jump_pressed and multiple.jump_released and multiple.jump_held, "V01 multiple events preserve both transitions and final state")
	var no_duplicate = controller.capture_snapshot()
	_expect_true(not no_duplicate.jump_pressed and not no_duplicate.jump_released and no_duplicate.jump_held, "V01 multiple events do not fire twice")
	_send_action_event(controller, &"jump", false)
	controller.capture_snapshot()
	controller.queue_free()


func _test_device_transition() -> void:
	var controller := Controller.new()
	root.add_child(controller)
	controller.aim_deadzone = 0.20
	_expect_eq(controller.resolve_aim_sector(Vector2.RIGHT, Vector2.LEFT), 0, "V02 valid stick has priority over mouse")
	_expect_eq(controller.resolve_aim_sector(Vector2(0.1, 0.0), Vector2.UP), 2, "V02 mouse takes control when stick enters deadzone")
	_expect_eq(controller.resolve_aim_sector(Vector2(0.1, 0.0), Vector2.UP), 2, "V02 transition is reproducible")
	controller.queue_free()


func _test_rapid_device_alternation() -> void:
	var controller := Controller.new()
	root.add_child(controller)
	controller.aim_deadzone = 0.20
	var expected: Array[int] = [4, 1, 6, 1, 4, 1, 6, 1]
	var actual: Array[int] = []
	for cycle in range(2):
		actual.append(controller.resolve_aim_sector(Vector2.ZERO, Vector2.LEFT))
		actual.append(controller.resolve_aim_sector(Vector2(1.0, -1.0), Vector2.DOWN))
		actual.append(controller.resolve_aim_sector(Vector2(0.1, 0.0), Vector2.DOWN))
		actual.append(controller.resolve_aim_sector(Vector2(1.0, -1.0), Vector2.DOWN))
	_expect_eq(actual, expected, "V03 rapid alternation is stable across repeated sequences")
	_expect_eq(controller.resolve_aim_sector(Vector2.LEFT, Vector2.RIGHT), 4, "V03 directional priority is independent from conflicting mouse")
	_expect_eq(controller.resolve_aim_sector(Vector2.LEFT, Vector2.RIGHT), 4, "V03 identical samples do not oscillate")
	controller.queue_free()


func _action_event(action: StringName, pressed: bool) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	return event


func _send_action_event(controller: Node, action: StringName, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)
	controller._input(_action_event(action, pressed))


func _expect_eq(actual: Variant, expected: Variant, label: String) -> void:
	_checks += 1
	if actual != expected:
		_failures += 1
		printerr("FAIL %s: expected %s, got %s" % [label, expected, actual])


func _expect_true(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures += 1
		printerr("FAIL %s" % label)
