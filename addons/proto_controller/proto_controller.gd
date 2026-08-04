extends CharacterBody3D

@export var mouse_sensitivity := 0.12

@export var sprint_speed := 15.0
@export var crouch_speed := 6.0
@export var air_speed := 7.0

@export var ground_friction := 22.0
@export var acceleration := 45.0
@export var air_acceleration := 18.0

@export var jump_velocity := 8.5
@export var gravity := 24.0
@export var slam_speed := 42.0
@export var max_fall_speed := 40.0

@export var dash_speed := 26.0
@export var dash_duration := 0.14
@export var dash_cooldown := 0.35

@export var slide_boost := 14.0
@export var slide_duration := 0.8
@export var slide_jump_boost := 5.0
@export var slide_drag := 4.0

@export var wall_jump_push := 10.0
@export var wall_jump_up := 9.0
@export var wall_jump_max_uses := 3
@export var wall_jump_cooldown := 0.12

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var head_pitch := 0.0
var was_on_floor := false

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector3.ZERO

var slide_timer := 0.0
var is_sliding := false
var is_slamming := false

var wall_jump_uses_left := 3
var wall_jump_lockout := 0.0
var last_wall_normal := Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	floor_stop_on_slope = true
	floor_constant_speed = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head_pitch = clamp(head_pitch - event.relative.y * mouse_sensitivity, -89.0, 89.0)
		head.rotation_degrees.x = head_pitch

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()
	var on_wall := is_on_wall_only()

	if on_floor:
		coyote_timer = coyote_time
		is_slamming = false
		wall_jump_uses_left = wall_jump_max_uses
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)
	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)
	wall_jump_lockout = maxf(wall_jump_lockout - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and dash_timer <= 0.0:
		_start_dash()

	if Input.is_action_just_pressed("crouch") and on_floor:
		_start_slide()

	if Input.is_action_just_pressed("crouch") and not on_floor and not is_slamming:
		_start_slam()

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir := _get_move_direction(input_dir)

	if dash_timer > 0.0:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		velocity.y = 0.0
	elif is_slamming:
		velocity.x = 0.0
		velocity.z = 0.0
		velocity.y = -slam_speed
	else:
		var target_speed := sprint_speed
		if Input.is_action_pressed("crouch") and on_floor:
			target_speed = crouch_speed
		if not on_floor:
			target_speed = air_speed

		var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)

		if on_floor:
			if wish_dir == Vector3.ZERO:
				horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, ground_friction * delta)
			else:
				horizontal_velocity = horizontal_velocity.move_toward(wish_dir * target_speed, acceleration * delta)
		else:
			if wish_dir != Vector3.ZERO:
				horizontal_velocity = horizontal_velocity.move_toward(wish_dir * target_speed, air_acceleration * delta)

		if is_sliding and on_floor:
			slide_timer -= delta
			var slide_dir := -transform.basis.z
			slide_dir.y = 0.0
			slide_dir = slide_dir.normalized()

			horizontal_velocity = horizontal_velocity.move_toward(slide_dir * sprint_speed * 1.15, slide_drag * delta)
			if slide_timer <= 0.0:
				is_sliding = false

		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z

		if jump_buffer_timer > 0.0:
			if coyote_timer > 0.0:
				velocity.y = jump_velocity
				jump_buffer_timer = 0.0
				coyote_timer = 0.0
				is_sliding = false
				is_slamming = false
			elif on_wall and wall_jump_uses_left > 0 and wall_jump_lockout <= 0.0:
				_do_wall_jump()
				jump_buffer_timer = 0.0

		if jump_buffer_timer > 0.0 and was_on_floor and is_sliding:
			velocity.y = jump_velocity + slide_jump_boost
			velocity += -transform.basis.z * slide_boost * 0.5
			jump_buffer_timer = 0.0
			is_sliding = false

		if not on_floor and not is_slamming:
			velocity.y -= gravity * delta
			velocity.y = maxf(velocity.y, -max_fall_speed)
		elif velocity.y < 0.0 and not is_slamming:
			velocity.y = 0.0

	move_and_slide()

	if is_on_wall_only():
		var c := get_last_slide_collision()
		if c:
			last_wall_normal = c.get_normal()

	if is_slamming and is_on_floor():
		is_slamming = false
		velocity.y = 0.0

	was_on_floor = is_on_floor()

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
	return (right * input_dir.x + forward * input_dir.y).normalized()

func _start_dash() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir := _get_move_direction(input_dir)

	if dir == Vector3.ZERO:
		dir = -transform.basis.z
		dir.y = 0.0
		dir = dir.normalized()

	dash_direction = dir
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	is_sliding = false
	slide_timer = 0.0
	is_slamming = false

func _start_slide() -> void:
	is_sliding = true
	slide_timer = slide_duration
	dash_cooldown_timer = maxf(dash_cooldown_timer, 0.15)
	is_slamming = false

func _start_slam() -> void:
	is_slamming = true
	is_sliding = false
	slide_timer = 0.0

func _do_wall_jump() -> void:
	wall_jump_uses_left -= 1
	wall_jump_lockout = wall_jump_cooldown

	var push_dir := last_wall_normal
	push_dir.y = 0.0
	if push_dir == Vector3.ZERO:
		push_dir = -transform.basis.z
	push_dir = push_dir.normalized()

	velocity.y = wall_jump_up
	velocity.x = push_dir.x * wall_jump_push
	velocity.z = push_dir.z * wall_jump_push

	is_sliding = false
	is_slamming = false
	dash_timer = 0.0
	
@onready var weapon = $Sword

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		weapon.attack()
