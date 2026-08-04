extends CharacterBody3D

@export var speed := 4.0
@export var gravity := 9.8
@export var player: Node3D

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var flat_player_pos := player.global_position
	flat_player_pos.y = global_position.y

	var dir := flat_player_pos - global_position
	dir.y = 0.0
	dir = dir.normalized()

	if dir != Vector3.ZERO:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
