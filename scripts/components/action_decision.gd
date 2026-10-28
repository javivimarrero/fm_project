class_name ActionDecision
extends RefCounted

var tick_id: int
var committed_action: int
var requested_actions: Array[int]
var rejected_actions: Dictionary
var cancel_reload: bool
var is_new_resolution: bool


func _init(
		tick: int,
		committed: int,
		requested: Array[int],
		rejected: Dictionary,
		should_cancel_reload: bool,
		is_new: bool = true
) -> void:
	tick_id = tick
	committed_action = committed
	requested_actions = requested.duplicate()
	rejected_actions = rejected.duplicate()
	cancel_reload = should_cancel_reload
	is_new_resolution = is_new
