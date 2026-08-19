extends Node3D

@export var sway_amount: float = 0.05
@export var sway_speed: float = 8.0
@export var bob_amount: float = 0.05
@export var bob_speed: float = 10.0
@export var tilt_amount: float = 5.0 # degrees

var target_pos: Vector3 = Vector3.ZERO
var bob_time: float = 0.0

@onready var player: CharacterBody3D = get_node("../../..") # adjust path to your player

func _process(delta: float) -> void:
	var mouse_rel: Vector2 = Input.get_last_mouse_velocity() / 1000.0

	# --- Sway based on mouse movement ---
	var sway_target := Vector3(
		clamp(-mouse_rel.x * sway_amount, -0.1, 0.1),
		clamp(mouse_rel.y * sway_amount, -0.1, 0.1),
		0
	)

	# --- Bob based on movement speed ---
	var velocity_flat := Vector2(player.velocity.x, player.velocity.z)
	var is_moving := velocity_flat.length() > 0.5 and player.is_on_floor()

	if is_moving:
		bob_time += delta * bob_speed
	else:
		bob_time = lerp(bob_time, 0.0, delta * 5.0)

	var bob_offset := Vector3(
		sin(bob_time) * bob_amount * 0.5,
		abs(sin(bob_time)) * bob_amount,
		0
	)

	target_pos = sway_target + bob_offset
	position = position.lerp(target_pos, delta * sway_speed)

	# --- Tilt on strafe ---
	var input_dir := Input.get_axis("move_left", "move_right") # adjust to your input names
	var target_tilt := -input_dir * deg_to_rad(tilt_amount)
	rotation.z = lerp_angle(rotation.z, target_tilt, delta * 8.0)
