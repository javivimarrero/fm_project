class_name ActionCoordinator
extends RefCounted

enum Action {
	NONE,
	DODGE,
	SHOOT,
	JUMP,
	RELOAD,
}

enum Rejection {
	NOT_AVAILABLE,
	DAMAGE_PENDING,
	RECOVERY_BLOCKED,
	ACTIVE_ACTION,
	TRANSITION_BLOCKED,
	LOWER_PRIORITY,
	DUPLICATE_TICK,
}

const PRIORITY: Array[int] = [Action.DODGE, Action.SHOOT, Action.JUMP, Action.RELOAD]

var last_resolved_tick: int = 0


## Resolves requests from one immutable snapshot. This method decides only;
## executors for future mechanics remain outside C04.
func resolve(snapshot: InputSnapshot, context: ActionContext) -> ActionDecision:
	var requested := _requests_from(snapshot)
	if snapshot.tick_id <= last_resolved_tick:
		var duplicate_rejections: Dictionary = {}
		for action in requested:
			duplicate_rejections[action] = Rejection.DUPLICATE_TICK
		return ActionDecision.new(
			snapshot.tick_id,
			Action.NONE,
			requested,
			duplicate_rejections,
			false,
			false
		)

	last_resolved_tick = snapshot.tick_id
	var rejected: Dictionary = {}
	var global_rejection := _global_rejection(context)
	if global_rejection >= 0:
		for action in requested:
			rejected[action] = global_rejection
		return ActionDecision.new(snapshot.tick_id, Action.NONE, requested, rejected, false)

	var committed := Action.NONE
	for action in requested:
		if not context.is_available(action):
			rejected[action] = Rejection.NOT_AVAILABLE
			continue
		if context.is_transition_blocked(action):
			rejected[action] = Rejection.TRANSITION_BLOCKED
			continue
		if committed == Action.NONE:
			committed = action
		else:
			rejected[action] = Rejection.LOWER_PRIORITY

	var cancels_reload := context.reload_in_progress and committed in [Action.DODGE, Action.SHOOT]
	return ActionDecision.new(snapshot.tick_id, committed, requested, rejected, cancels_reload)


func reset() -> void:
	last_resolved_tick = 0


func _requests_from(snapshot: InputSnapshot) -> Array[int]:
	var requests: Array[int] = []
	if snapshot.dodge_pressed:
		requests.append(Action.DODGE)
	if snapshot.shoot_pressed:
		requests.append(Action.SHOOT)
	if snapshot.jump_pressed:
		requests.append(Action.JUMP)
	if snapshot.reload_pressed:
		requests.append(Action.RELOAD)
	return requests


func _global_rejection(context: ActionContext) -> int:
	if context.damage_resolution_pending:
		return Rejection.DAMAGE_PENDING
	if context.recovery_blocks_new_actions:
		return Rejection.RECOVERY_BLOCKED
	if context.active_action != Action.NONE:
		return Rejection.ACTIVE_ACTION
	return -1
