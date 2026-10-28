class_name ActionContext
extends RefCounted

## Explicit capabilities supplied by the systems that execute each action.
## C04 only enables jump because later mechanics are not implemented yet.
var allow_dodge: bool = false
var allow_shoot: bool = false
var allow_jump: bool = true
var allow_reload: bool = false

## Previously confirmed damage and recoveries are resolved before new actions.
var damage_resolution_pending: bool = false
var recovery_blocks_new_actions: bool = false
var active_action: int = 0

## Future executors can prohibit individual transitions without teaching the
## coordinator their gameplay internals.
var blocked_actions: Array[int] = []
var reload_in_progress: bool = false


func is_available(action: int) -> bool:
	match action:
		1:
			return allow_dodge
		2:
			return allow_shoot
		3:
			return allow_jump
		4:
			return allow_reload
		_:
			return false


func is_transition_blocked(action: int) -> bool:
	return blocked_actions.has(action)
