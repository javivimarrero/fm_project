class_name InputController
extends Node

const Snapshot := preload("res://scripts/components/input_snapshot.gd")
const Quantizer := preload("res://scripts/components/aim_quantizer.gd")
const BUTTON_ACTIONS: Array[StringName] = [&"jump", &"dodge", &"shoot", &"reload", &"lock_target"]

## Provisional C02 value. It can be tuned by a later authorized task.
@export_range(0.0, 1.0, 0.01) var aim_deadzone: float = 0.20
## Temporary reference point because C02 deliberately has no player node.
@export var mouse_aim_origin: Vector2 = Vector2.ZERO

var latest_snapshot: InputSnapshot
var _tick_id: int = 0
var _last_aim_sector: int = 0
var _observed_button_states: Dictionary = {}
var _pending_button_transitions: Dictionary = {}


func _ready() -> void:
	for action in BUTTON_ACTIONS:
		_observed_button_states[action] = Input.is_action_pressed(action)
		_pending_button_transitions[action] = _empty_transition()


func _input(event: InputEvent) -> void:
	for action in BUTTON_ACTIONS:
		if not event.is_action(action):
			continue
		if event is InputEventKey and event.echo:
			continue

		var held: bool = _observed_button_states.get(action, false)
		var transition: Dictionary = _pending_button_transitions.get(action, _empty_transition())
		if event.is_pressed() and not held:
			transition.pressed = true
			_observed_button_states[action] = true
		elif event.is_released() and held:
			transition.released = true
			_observed_button_states[action] = false
		_pending_button_transitions[action] = transition


func _physics_process(_delta: float) -> void:
	latest_snapshot = capture_snapshot()


## Device policy: a valid directional action (keyboard I/J/K/L or right stick)
## takes priority over mouse position. Otherwise a non-zero mouse vector is
## used. Invalid/neutral input preserves the last valid sector.
func capture_snapshot() -> InputSnapshot:
	_tick_id += 1
	var movement := Input.get_axis(&"move_left", &"move_right")
	var digital_or_stick := Input.get_vector(&"aim_left", &"aim_right", &"aim_up", &"aim_down")
	var mouse_vector := get_viewport().get_mouse_position() - mouse_aim_origin
	_last_aim_sector = resolve_aim_sector(digital_or_stick, mouse_vector)
	var quantized_direction := Quantizer.direction_for_sector(_last_aim_sector)

	var jump_state := _sample_button(&"jump")
	var dodge_state := _sample_button(&"dodge")
	var shoot_state := _sample_button(&"shoot")
	var reload_state := _sample_button(&"reload")
	var lock_state := _sample_button(&"lock_target")

	return Snapshot.new(
		_tick_id,
		movement,
		quantized_direction,
		_last_aim_sector,
		jump_state,
		dodge_state,
		shoot_state,
		reload_state,
		lock_state
	)


func _sample_button(action: StringName) -> Dictionary:
	var actual_held := Input.is_action_pressed(action)
	var observed_held: bool = _observed_button_states.get(action, actual_held)
	var transition: Dictionary = _pending_button_transitions.get(action, _empty_transition())

	# Input.action_press/release does not emit _input(), so synchronize it here.
	# Hardware events have already been accumulated without losing transitions.
	if actual_held != observed_held:
		transition.pressed = actual_held
		transition.released = not actual_held
		observed_held = actual_held

	_observed_button_states[action] = observed_held
	_pending_button_transitions[action] = _empty_transition()
	return {
		&"pressed": transition.pressed,
		&"held": observed_held,
		&"released": transition.released,
	}


## Pure-priority inputs are sampled before this call, so event delivery order
## cannot affect the result: directional input wins, then mouse, then previous.
func resolve_aim_sector(directional_vector: Vector2, mouse_vector: Vector2) -> int:
	var selected_aim := Vector2.ZERO
	if directional_vector.length() > aim_deadzone:
		selected_aim = directional_vector
	elif not mouse_vector.is_zero_approx():
		selected_aim = mouse_vector
	_last_aim_sector = Quantizer.quantize(selected_aim, _last_aim_sector, aim_deadzone)
	return _last_aim_sector


func _empty_transition() -> Dictionary:
	return {&"pressed": false, &"released": false}
