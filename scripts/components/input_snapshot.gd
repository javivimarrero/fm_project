class_name InputSnapshot
extends RefCounted

## Read-only view of all input sampled for one physics tick.
## Values are copied into private storage during construction. Consumers should
## only use the properties below and never mutate the backing fields.

var tick_id: int:
	get: return _tick_id
var move_axis: float:
	get: return _move_axis
var aim_direction: Vector2:
	get: return _aim_direction
var aim_sector: int:
	get: return _aim_sector
var jump_pressed: bool:
	get: return _jump_pressed
var jump_held: bool:
	get: return _jump_held
var jump_released: bool:
	get: return _jump_released
var dodge_pressed: bool:
	get: return _dodge_pressed
var dodge_held: bool:
	get: return _dodge_held
var dodge_released: bool:
	get: return _dodge_released
var shoot_pressed: bool:
	get: return _shoot_pressed
var shoot_held: bool:
	get: return _shoot_held
var shoot_released: bool:
	get: return _shoot_released
var reload_pressed: bool:
	get: return _reload_pressed
var reload_held: bool:
	get: return _reload_held
var reload_released: bool:
	get: return _reload_released
var lock_pressed: bool:
	get: return _lock_pressed
var lock_held: bool:
	get: return _lock_held
var lock_released: bool:
	get: return _lock_released

var _tick_id: int
var _move_axis: float
var _aim_direction: Vector2
var _aim_sector: int
var _jump_pressed: bool
var _jump_held: bool
var _jump_released: bool
var _dodge_pressed: bool
var _dodge_held: bool
var _dodge_released: bool
var _shoot_pressed: bool
var _shoot_held: bool
var _shoot_released: bool
var _reload_pressed: bool
var _reload_held: bool
var _reload_released: bool
var _lock_pressed: bool
var _lock_held: bool
var _lock_released: bool


func _init(
		tick: int,
		movement: float,
		aim: Vector2,
		sector: int,
		jump_state: Dictionary,
		dodge_state: Dictionary,
		shoot_state: Dictionary,
		reload_state: Dictionary,
		lock_state: Dictionary
) -> void:
	_tick_id = tick
	_move_axis = clampf(movement, -1.0, 1.0)
	_aim_direction = aim
	_aim_sector = sector
	_jump_pressed = jump_state.pressed
	_jump_held = jump_state.held
	_jump_released = jump_state.released
	_dodge_pressed = dodge_state.pressed
	_dodge_held = dodge_state.held
	_dodge_released = dodge_state.released
	_shoot_pressed = shoot_state.pressed
	_shoot_held = shoot_state.held
	_shoot_released = shoot_state.released
	_reload_pressed = reload_state.pressed
	_reload_held = reload_state.held
	_reload_released = reload_state.released
	_lock_pressed = lock_state.pressed
	_lock_held = lock_state.held
	_lock_released = lock_state.released
