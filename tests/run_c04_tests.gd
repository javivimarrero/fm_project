extends SceneTree

const Coordinator := preload("res://scripts/components/action_coordinator.gd")
const Context := preload("res://scripts/components/action_context.gd")
const Snapshot := preload("res://scripts/components/input_snapshot.gd")
const Arena := preload("res://scenes/prototypes/duel_arena.tscn")

var _failures: int = 0
var _checks: int = 0
var _tick: int = 0


func _initialize() -> void:
	call_deferred(&"_run_tests")


func _run_tests() -> void:
	_test_deterministic_priority()
	_test_unavailable_and_blocked_transitions()
	_test_global_blocks()
	_test_single_commit_and_duplicate_tick()
	_test_reload_cancellation_contract()
	_test_no_implicit_queue()
	await _test_player_integration()

	if _failures == 0:
		print("C04 TESTS PASSED: %d checks" % _checks)
		quit(0)
	else:
		printerr("C04 TESTS FAILED: %d of %d checks" % [_failures, _checks])
		quit(1)


func _test_deterministic_priority() -> void:
	var coordinator := Coordinator.new()
	var context := _all_enabled_context()
	var decision := coordinator.resolve(_snapshot(true, true, true, true), context)
	_expect_eq(decision.requested_actions, [1, 2, 3, 4], "requests retain contractual priority")
	_expect_eq(decision.committed_action, Coordinator.Action.DODGE, "dodge wins simultaneous requests")
	_expect_eq(decision.rejected_actions[Coordinator.Action.SHOOT], Coordinator.Rejection.LOWER_PRIORITY, "shoot loses to dodge")
	_expect_eq(decision.rejected_actions[Coordinator.Action.JUMP], Coordinator.Rejection.LOWER_PRIORITY, "jump loses to dodge")
	_expect_eq(decision.rejected_actions[Coordinator.Action.RELOAD], Coordinator.Rejection.LOWER_PRIORITY, "reload loses to dodge")

	coordinator.reset()
	decision = coordinator.resolve(_snapshot(false, true, true, true), context)
	_expect_eq(decision.committed_action, Coordinator.Action.SHOOT, "shoot wins over jump and reload")
	coordinator.reset()
	decision = coordinator.resolve(_snapshot(false, false, true, true), context)
	_expect_eq(decision.committed_action, Coordinator.Action.JUMP, "jump wins over reload")


func _test_unavailable_and_blocked_transitions() -> void:
	var coordinator := Coordinator.new()
	var context := Context.new()
	var decision := coordinator.resolve(_snapshot(true, true, true), context)
	_expect_eq(decision.committed_action, Coordinator.Action.JUMP, "unimplemented actions are rejected before allowed jump")
	_expect_eq(decision.rejected_actions[Coordinator.Action.DODGE], Coordinator.Rejection.NOT_AVAILABLE, "unavailable dodge is rejected")
	_expect_eq(decision.rejected_actions[Coordinator.Action.SHOOT], Coordinator.Rejection.NOT_AVAILABLE, "unavailable shoot is rejected")

	coordinator.reset()
	context = _all_enabled_context()
	context.blocked_actions = [Coordinator.Action.DODGE]
	decision = coordinator.resolve(_snapshot(true, true), context)
	_expect_eq(decision.committed_action, Coordinator.Action.SHOOT, "blocked transition falls through to next allowed request")
	_expect_eq(decision.rejected_actions[Coordinator.Action.DODGE], Coordinator.Rejection.TRANSITION_BLOCKED, "blocked transition has explicit reason")


func _test_global_blocks() -> void:
	var context := _all_enabled_context()
	context.damage_resolution_pending = true
	var decision := Coordinator.new().resolve(_snapshot(false, false, true), context)
	_expect_eq(decision.committed_action, Coordinator.Action.NONE, "pending damage blocks new actions")
	_expect_eq(decision.rejected_actions[Coordinator.Action.JUMP], Coordinator.Rejection.DAMAGE_PENDING, "damage rejection is explicit")

	context = _all_enabled_context()
	context.recovery_blocks_new_actions = true
	decision = Coordinator.new().resolve(_snapshot(false, true), context)
	_expect_eq(decision.committed_action, Coordinator.Action.NONE, "recovery blocks new actions")
	_expect_eq(decision.rejected_actions[Coordinator.Action.SHOOT], Coordinator.Rejection.RECOVERY_BLOCKED, "recovery rejection is explicit")

	context = _all_enabled_context()
	context.active_action = Coordinator.Action.DODGE
	decision = Coordinator.new().resolve(_snapshot(false, false, false, true), context)
	_expect_eq(decision.committed_action, Coordinator.Action.NONE, "active action prevents contradictory commitment")
	_expect_eq(decision.rejected_actions[Coordinator.Action.RELOAD], Coordinator.Rejection.ACTIVE_ACTION, "active-action rejection is explicit")


func _test_single_commit_and_duplicate_tick() -> void:
	var coordinator := Coordinator.new()
	var context := _all_enabled_context()
	var snapshot := _snapshot(false, true, true, true)
	var decision := coordinator.resolve(snapshot, context)
	_expect_eq(decision.committed_action, Coordinator.Action.SHOOT, "only highest allowed action commits")
	_expect_eq(decision.rejected_actions.size(), 2, "all lower simultaneous requests are rejected")
	var duplicate := coordinator.resolve(snapshot, context)
	_expect_true(not duplicate.is_new_resolution, "same tick cannot resolve twice")
	_expect_eq(duplicate.committed_action, Coordinator.Action.NONE, "duplicate tick cannot commit another action")
	_expect_eq(duplicate.rejected_actions[Coordinator.Action.SHOOT], Coordinator.Rejection.DUPLICATE_TICK, "duplicate rejection is explicit")


func _test_reload_cancellation_contract() -> void:
	var context := _all_enabled_context()
	context.reload_in_progress = true
	var dodge := Coordinator.new().resolve(_snapshot(true), context)
	_expect_true(dodge.cancel_reload, "dodge decision requests reload cancellation")
	var shoot := Coordinator.new().resolve(_snapshot(false, true), context)
	_expect_true(shoot.cancel_reload, "shoot decision requests reload cancellation")
	var jump := Coordinator.new().resolve(_snapshot(false, false, true), context)
	_expect_true(not jump.cancel_reload, "jump does not invent reload cancellation")


func _test_no_implicit_queue() -> void:
	var coordinator := Coordinator.new()
	var context := _all_enabled_context()
	context.recovery_blocks_new_actions = true
	var blocked := coordinator.resolve(_snapshot(false, true), context)
	_expect_eq(blocked.committed_action, Coordinator.Action.NONE, "blocked request does not commit")
	context.recovery_blocks_new_actions = false
	var later := coordinator.resolve(_snapshot(), context)
	_expect_eq(later.committed_action, Coordinator.Action.NONE, "blocked request is not queued for a later tick")
	_expect_true(later.requested_actions.is_empty(), "neutral later snapshot stays neutral")


func _test_player_integration() -> void:
	var arena := Arena.instantiate()
	root.add_child(arena)
	await physics_frame
	await physics_frame
	var player: Player = arena.get_node("Player")
	player.action_context.recovery_blocks_new_actions = true
	Input.action_press(&"jump")
	await physics_frame
	Input.action_release(&"jump")
	await physics_frame
	_expect_eq(player.latest_action_decision.committed_action, Coordinator.Action.NONE, "player respects coordinator recovery block")
	_expect_true(player.velocity.y >= 0.0, "rejected jump is not executed or buffered")

	player.action_context.recovery_blocks_new_actions = false
	await physics_frame
	_expect_true(player.velocity.y >= 0.0, "rejected jump does not appear as an implicit queue")
	Input.action_press(&"jump")
	await physics_frame
	Input.action_release(&"jump")
	_expect_eq(player.latest_action_decision.committed_action, Coordinator.Action.JUMP, "fresh allowed jump is committed")
	_expect_true(player.velocity.y < 0.0, "committed jump remains compatible with C03 movement")
	arena.queue_free()


func _all_enabled_context() -> ActionContext:
	var context := Context.new()
	context.allow_dodge = true
	context.allow_shoot = true
	context.allow_jump = true
	context.allow_reload = true
	return context


func _snapshot(dodge: bool = false, shoot: bool = false, jump: bool = false, reload: bool = false) -> InputSnapshot:
	_tick += 1
	var neutral := {&"pressed": false, &"held": false, &"released": false}
	var dodge_state := {&"pressed": dodge, &"held": dodge, &"released": false}
	var shoot_state := {&"pressed": shoot, &"held": shoot, &"released": false}
	var jump_state := {&"pressed": jump, &"held": jump, &"released": false}
	var reload_state := {&"pressed": reload, &"held": reload, &"released": false}
	return Snapshot.new(_tick, 0.0, Vector2.RIGHT, 0, jump_state, dodge_state, shoot_state, reload_state, neutral)


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
