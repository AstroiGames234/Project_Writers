extends CharacterBody3D


@export var mouse_sensitivity := 0.12

@export var sprint_speed := 15.0
@export var crouch_speed := 25.0
@export var air_speed := 7.0

@export var ground_friction := 22.0
@export var air_friction := 0.5

@export var acceleration := 45.0
@export var air_acceleration := 18.0

@export var jump_velocity := 8.5
@export var gravity := 24.0
@export var slam_speed := 42.0
@export var max_fall_speed := 40.0

@export var dash_speed := 26.0
@export var dash_duration := 0.14
@export var dash_cooldown := 0.35

@export var lunge_cooldown := 0.6

@export var slide_jump_boost := 5.0

@export var wall_jump_push := 10.0
@export var wall_jump_up := 9.0
@export var wall_jump_max_uses := 3
@export var wall_jump_cooldown := 0.12

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12


# Slide boost
@export var slide_boost_speed := 28.0
@export var slide_boost_duration := 10.0
@export var slide_steer_speed := 4.0
@export var slide_release_grace := 0.2


# Slide crouch
@export var slide_crouch_amount := 0.5
@export var crouch_transition_speed := 10.0


# Dash invulnerability
@export var dash_invul_duration := 0.6


# Slam hitbox
@export var slam_damage: int = 2
@export var slam_hitbox_duration: float = 0.15


@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

# NOTE: adjust this path to wherever WeaponHolder actually lives in your
# tree. Based on our earlier setup it should be:
# Head/Camera3D/HandPivot/WeaponHolder
@onready var weapon_manager: Node3D = $Head/Camera3D/HandPivot/WeaponHolder

@onready var slam_hitbox: Area3D = $SlamHitbox
@onready var slam_hitbox_shape: CollisionShape3D = $SlamHitbox/colission
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var collision_shape: CollisionShape3D = $Collider


var head_pitch := 0.0
var was_on_floor := false

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector3.ZERO

var lunge_cooldown_timer := 0.0

var is_sliding := false
var is_slamming := false

var wall_jump_uses_left := 3
var wall_jump_lockout := 0.0
var last_wall_normal := Vector3.ZERO


# Invulnerability state
var dash_invul_timer := 0.0
var is_invulnerable := false


# Slide boost state
var slide_boost_timer := 0.0
var slide_boost_direction := Vector3.ZERO
var slide_boost_vector := Vector3.ZERO
var slide_release_timer := 0.0


# Crouch state
var crouch_offset := 0.0
var standing_head_y := 0.0
var standing_shape_height := 0.0
var standing_shape_position_y := 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	floor_stop_on_slope = true
	floor_constant_speed = false
	floor_snap_length = 0.3

	slam_hitbox.monitoring = false
	slam_hitbox.monitorable = false
	slam_hitbox_shape.disabled = true

	standing_head_y = head.position.y

	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape

		if shape is CapsuleShape3D or shape is CylinderShape3D:
			standing_shape_height = shape.height
			standing_shape_position_y = collision_shape.position.y


@export var base_sensitivity: float = 0.1 

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sens = base_sensitivity * SettingsManager.mouse_sensitivity
		rotate_y(deg_to_rad(-event.relative.x * sens))
		head_pitch = clamp(
			head_pitch - event.relative.y * sens,
			-89.0,
			89.0
		)
		head.rotation_degrees.x = head_pitch
	if event.is_action_pressed("ui_cancel"):
		pass

func _unhandled_input(event: InputEvent) -> void:
	# --- Weapon switching ---
	if event.is_action_pressed("weapon_1"):
		weapon_manager.switch_to(0)
	elif event.is_action_pressed("weapon_2"):
		weapon_manager.switch_to(1)
	elif event.is_action_pressed("switch_variant"):
		weapon_manager.cycle_variant()

	# --- Attacks ---
	# Primary attack: whatever the currently equipped weapon does on
	# primary_attack() (sword swing, dagger throw, etc). The weapon's own
	# script is responsible for playing its own animation.
	if event.is_action_pressed("attack_primary"):
		weapon_manager.fire_primary()

	# Secondary attack: e.g. the sword's lunge. Movement (the dash) still
	# lives here in the player script since it's not weapon-specific, but
	# the weapon's own secondary_attack() handles its side of it
	# (animation, extra damage, whatever).
	if event.is_action_pressed("attack_secondary") and lunge_cooldown_timer <= 0.0:
		var w = weapon_manager.current_weapon()
		weapon_manager.fire_secondary()
		if w and w.secondary_uses_dash:
			lunge_cooldown_timer = lunge_cooldown
			_start_dash()
		


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()
	var on_wall := is_on_wall_only()

	# Ground and coyote-time handling.
	if on_floor:
		coyote_timer = coyote_time
		is_slamming = false
		wall_jump_uses_left = wall_jump_max_uses
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	var can_slide := on_floor or coyote_timer > 0.0

	# Update timers.
	jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)
	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)
	wall_jump_lockout = maxf(wall_jump_lockout - delta, 0.0)
	lunge_cooldown_timer = maxf(lunge_cooldown_timer - delta, 0.0)

	# Update dash invulnerability.
	if dash_invul_timer > 0.0:
		dash_invul_timer -= delta

		if dash_invul_timer <= 0.0:
			dash_invul_timer = 0.0
			is_invulnerable = false

	# Jump input buffer.
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	# Dash input.
	if (
		Input.is_action_just_pressed("dash")
		and dash_cooldown_timer <= 0.0
		and dash_timer <= 0.0
	):
		_start_dash()

	# Start a slide while grounded or during coyote time.
	if Input.is_action_just_pressed("crouch") and can_slide:
		_start_slide()

	# Keep the slide boost alive while crouching.
	if Input.is_action_pressed("crouch"):
		slide_release_timer = slide_release_grace

	# Stop sliding when airborne past coyote time, or when crouch is released.
	if is_sliding:
		if not on_floor and coyote_timer <= 0.0:
			is_sliding = false
		elif not Input.is_action_pressed("crouch"):
			is_sliding = false

	# Keep the slide boost alive while airborne.
	if not on_floor:
		slide_release_timer = slide_release_grace
	elif slide_boost_timer > 0.0:
		slide_release_timer = maxf(slide_release_timer - delta, 0.0)

	if slide_release_timer <= 0.0:
		slide_boost_timer = 0.0

	# Start a slam only when definitely airborne.
	if (
		Input.is_action_just_pressed("crouch")
		and not can_slide
		and not is_slamming
	):
		_start_slam()

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var wish_dir := _get_move_direction(input_dir)

	# Remove the previous frame's slide boost.
	velocity.x -= slide_boost_vector.x
	velocity.z -= slide_boost_vector.z

	if slide_boost_timer > 0.0:
		slide_boost_timer = maxf(slide_boost_timer - delta, 0.0)

		# Only steer the slide boost when a movement key is actually
		# held. With no input, keep the current direction instead of
		# drifting toward wherever the camera happens to be facing.
		if wish_dir != Vector3.ZERO:
			slide_boost_direction = slide_boost_direction.slerp(
				wish_dir,
				clampf(slide_steer_speed * delta, 0.0, 1.0)
			)

		var boost_strength := (
			slide_boost_speed
			* (slide_boost_timer / slide_boost_duration)
		)

		slide_boost_vector = slide_boost_direction * boost_strength
	else:
		slide_boost_vector = Vector3.ZERO

	# Dash movement.
	if dash_timer > 0.0:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		velocity.y = 0.0

	# Slam movement.
	elif is_slamming:
		velocity.x = 0.0
		velocity.z = 0.0
		velocity.y = -slam_speed

	# Normal movement.
	else:
		var target_speed := sprint_speed

		if Input.is_action_pressed("crouch") and can_slide:
			target_speed = crouch_speed

		if not on_floor:
			target_speed = air_speed

		var horizontal_velocity := Vector3(
			velocity.x,
			0.0,
			velocity.z
		)

		# Ground movement.
		if on_floor:
			if wish_dir == Vector3.ZERO:
				horizontal_velocity = horizontal_velocity.move_toward(
					Vector3.ZERO,
					ground_friction * delta
				)
			else:
				horizontal_velocity = horizontal_velocity.move_toward(
					wish_dir * target_speed,
					acceleration * delta
				)

		# Air movement with light air friction.
		else:
			# Retain air_friction of the velocity every second.
			# With air_friction = 0.5, half the velocity is retained
			# after one second.
			var friction_multiplier := pow(air_friction, delta)
			horizontal_velocity *= friction_multiplier

			if wish_dir != Vector3.ZERO:
				# Check how much velocity already exists in the input direction.
				var current_speed := horizontal_velocity.dot(wish_dir)

				# Only add velocity when below the desired air speed.
				var speed_to_add := target_speed - current_speed

				if speed_to_add > 0.0:
					var acceleration_amount := minf(
						air_acceleration * delta,
						speed_to_add
					)

					horizontal_velocity += wish_dir * acceleration_amount

		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z

		# Re-apply this frame's slide boost.
		if dash_timer <= 0.0 and not is_slamming:
			velocity.x += slide_boost_vector.x
			velocity.z += slide_boost_vector.z

		# Normal jump or wall jump.
		if jump_buffer_timer > 0.0:
			if coyote_timer > 0.0:
				velocity.y = jump_velocity

				jump_buffer_timer = 0.0
				coyote_timer = 0.0

				is_sliding = false
				is_slamming = false

				audio.play()

			elif on_wall and wall_jump_uses_left > 0 and wall_jump_lockout <= 0.0:
				_do_wall_jump()
				jump_buffer_timer = 0.0

		# Slide jump.
		if jump_buffer_timer > 0.0 and was_on_floor and is_sliding:
			velocity.y = jump_velocity + slide_jump_boost

			jump_buffer_timer = 0.0
			is_sliding = false

			audio.play()

	# Gravity.
	if not on_floor and not is_slamming:
		velocity.y -= gravity * delta
		velocity.y = maxf(velocity.y, -max_fall_speed)
	elif not is_slamming and velocity.y <= 0.0:
		velocity.y = -2.0

	move_and_slide()

	# Store the latest wall normal.
	if is_on_wall_only():
		var collision := get_last_slide_collision()

		if collision:
			last_wall_normal = collision.get_normal()

	# Stop the slam after landing.
	if is_slamming and is_on_floor():
		is_slamming = false
		velocity.y = 0.0
		_trigger_slam_hitbox()

	_update_crouch(delta)

	was_on_floor = on_floor


func _get_move_direction(input_dir: Vector2) -> Vector3:
	if input_dir == Vector2.ZERO:
		return Vector3.ZERO

	var basis := global_transform.basis

	var forward := -basis.z
	var right := basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	return (
		right * input_dir.x
		+ forward * input_dir.y
	).normalized()


func _start_dash() -> void:
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var dir := _get_move_direction(input_dir)

	if dir == Vector3.ZERO:
		dir = -transform.basis.z
		dir.y = 0.0
		dir = dir.normalized()

	dash_direction = dir
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

	is_sliding = false
	is_slamming = false
	slide_boost_timer = 0.0
	slide_boost_vector = Vector3.ZERO

	# Start dash invulnerability.
	dash_invul_timer = dash_invul_duration
	is_invulnerable = true


func _start_slide() -> void:
	is_sliding = true
	dash_cooldown_timer = maxf(dash_cooldown_timer, 0.15)
	is_slamming = false

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var dir := _get_move_direction(input_dir)

	if dir == Vector3.ZERO:
		dir = -transform.basis.z
		dir.y = 0.0
		dir = dir.normalized()

	slide_boost_direction = dir
	slide_boost_timer = slide_boost_duration
	slide_release_timer = slide_release_grace


func _start_slam() -> void:
	is_slamming = true
	is_sliding = false
	slide_boost_timer = 0.0
	slide_boost_vector = Vector3.ZERO


func _trigger_slam_hitbox() -> void:
	slam_hitbox.monitoring = true
	slam_hitbox.monitorable = true
	slam_hitbox_shape.disabled = false

	# Wait one physics frame so overlaps are registered.
	await get_tree().physics_frame

	var bodies := slam_hitbox.get_overlapping_bodies()

	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(slam_damage)

	await get_tree().create_timer(slam_hitbox_duration).timeout

	slam_hitbox.monitoring = false
	slam_hitbox.monitorable = false
	slam_hitbox_shape.disabled = true


func _do_wall_jump() -> void:
	wall_jump_uses_left -= 1
	wall_jump_lockout = wall_jump_cooldown

	var push_dir := last_wall_normal
	push_dir.y = 0.0

	if push_dir == Vector3.ZERO:
		push_dir = -transform.basis.z
		push_dir.y = 0.0

	push_dir = push_dir.normalized()

	# Preserve the current horizontal momentum.
	var horizontal_velocity := Vector3(
		velocity.x,
		0.0,
		velocity.z
	)

	# Add the wall push instead of replacing the velocity.
	horizontal_velocity += push_dir * wall_jump_push

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	velocity.y = wall_jump_up

	is_sliding = false
	is_slamming = false
	dash_timer = 0.0
	slide_boost_timer = 0.0
	slide_boost_vector = Vector3.ZERO

	audio.play()


func _update_crouch(delta: float) -> void:
	var target_offset := slide_crouch_amount if is_sliding else 0.0

	crouch_offset = move_toward(
		crouch_offset,
		target_offset,
		crouch_transition_speed * delta
	)

	head.position.y = standing_head_y - crouch_offset

	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape

		if shape is CapsuleShape3D or shape is CylinderShape3D:
			shape.height = maxf(
				standing_shape_height - crouch_offset,
				0.2
			)

			collision_shape.position.y = (
				standing_shape_position_y
				- crouch_offset * 0.5
			)


func is_currently_invulnerable() -> bool:
	return is_invulnerable

func get_weapon_manager() -> Node:
	return weapon_manager
