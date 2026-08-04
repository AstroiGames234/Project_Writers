extends CharacterBody2D


@export var speed: float = 1

const screen_movement_margin: int = 4

@onready var player_sprite_size: Vector2 = $Sprite2D.texture.get_size()
@onready var scaled_speed = speed * get_viewport().get_visible_rect().size.x
@onready var screen_size = Vector2(get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y)


func _physics_process(delta):
	_handle_movement(delta)


func _handle_movement(delta: float):
	var direction = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_LEFT):
		direction += Vector2.LEFT
	if Input.is_key_pressed(KEY_RIGHT):
		direction += Vector2.RIGHT
	if Input.is_key_pressed(KEY_UP):
		direction += Vector2.UP
	if Input.is_key_pressed(KEY_DOWN):
		direction += Vector2.DOWN
	
	velocity = direction.normalized() * scaled_speed
	move_and_slide()
	
	var min_x_move = player_sprite_size.x / 2 + screen_movement_margin
	var min_y_move = player_sprite_size.y / 2 + screen_movement_margin
	var max_x_move = screen_size.x - player_sprite_size.x / 2 - screen_movement_margin
	var max_y_move = screen_size.y - player_sprite_size.y / 2 - screen_movement_margin
	
	position.x = clamp(position.x, min_x_move, max_x_move)
	position.y = clamp(position.y, min_y_move, max_y_move)
