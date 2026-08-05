extends CharacterBody3D

const SPEED: float = 5.0

@export var player_path: NodePath

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: EnemyHealth = $EnemyHealth
var player: Node3D = null

func _ready() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path) as Node3D

	if health != null:
		health.died.connect(_on_died)

	print("Enemy spawned")

func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	if nav_agent == null:
		return

	nav_agent.target_position = player.global_position
	var next_nav_point: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_nav_point - global_position).normalized()

	velocity = direction * SPEED
	move_and_slide()

func take_damage(amount: int) -> void:
	if health != null and is_instance_valid(health):
		health.take_damage(amount)

func _on_died() -> void:
	print("Enemy died")
	set_process(false)
	set_physics_process(false)
	queue_free()
