extends CharacterBody3D


const SPEED: float = 8.0


@export var player_path: NodePath
@export var attack_range: float = 2.5
@export var attack_cooldown: float = 1.0
@export var attack_duration: float = 0.15


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var enemy_health: Node = $EnemyHealth
@onready var hitbox: Area3D = $Area3D
@onready var hitbox_shape: CollisionShape3D = $Area3D/CollisionShape3D


var player: Node3D = null
var attack_timer: float = 0.0
var is_attacking: bool = false


func _ready() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path) as Node3D
	else:
		player = get_tree().current_scene.find_child("Player", true, false) as Node3D

	# Completely disable the attack hitbox at startup.
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true

	call_deferred("setup_navigation")


func setup_navigation() -> void:
	await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	if attack_timer > 0.0:
		attack_timer -= delta

	if is_player_in_attack_range():
		velocity = Vector3.ZERO
		move_and_slide()

		if attack_timer <= 0.0 and not is_attacking:
			_attack()

		return

	nav_agent.target_position = player.global_position

	var next_point := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_point)

	velocity = direction * SPEED
	move_and_slide()


func is_player_in_attack_range() -> bool:
	var enemy_position := global_position
	var player_position := player.global_position

	enemy_position.y = 0.0
	player_position.y = 0.0

	return enemy_position.distance_to(player_position) <= attack_range


func _attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown

	hitbox.begin_attack()

	# Enable the entire hitbox.
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox_shape.disabled = false

	await get_tree().create_timer(attack_duration).timeout

	# Disable the entire hitbox.
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true

	is_attacking = false


func take_damage(amount: int) -> void:
	print("Enemy received damage: ", amount)

	if enemy_health != null and enemy_health.has_method("take_damage"):
		enemy_health.take_damage(amount)
	
