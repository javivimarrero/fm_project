class_name Player
extends CharacterBody2D

@export var input_controller_path: NodePath
@export var movement: MovementComponent = MovementComponent.new()

var last_consumed_tick: int = 0
var consumed_snapshot_count: int = 0
var action_context := ActionContext.new()
var action_coordinator := ActionCoordinator.new()
var latest_action_decision: ActionDecision

@onready var _input_controller: InputController = get_node(input_controller_path)


func _physics_process(delta: float) -> void:
	var snapshot := _input_controller.latest_snapshot
	if snapshot == null or snapshot.tick_id == last_consumed_tick:
		return

	last_consumed_tick = snapshot.tick_id
	consumed_snapshot_count += 1
	latest_action_decision = action_coordinator.resolve(snapshot, action_context)
	var jump_press_accepted := (
		latest_action_decision.committed_action == ActionCoordinator.Action.JUMP
	)
	velocity = movement.step_velocity(
		velocity,
		snapshot,
		delta,
		is_on_floor(),
		jump_press_accepted
	)
	move_and_slide()
