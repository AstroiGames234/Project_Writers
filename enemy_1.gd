extends CharacterBody3D

const SPEED: float = 5.0

@export var player_path: NodePath

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: Node = $EnemyHealth # Changed type to Node for safety, adjust if needed
var player: Node3D = null

func _ready() -> void:
	# 1. Setup the player target safely
	if player_path != NodePath():
		player = get_node_or_null(player_path) as Node3D
	else:
		# If spawned via code, search the scene tree for a node named "Player"
		player = get_tree().current_scene.find_child("Player", true, false) as Node3D

	# 2. Connect health signal
	if health != null:
		health.died.connect(_on_died)

	# 3. Godot 4 Navigation fix: Wait 1 frame for the NavigationServer to sync
	call_deferred("setup_navigation")
	print("Enemy spawned")

func setup_navigation() -> void:
	# Wait for physics map synchronization so NavigationAgent doesn't break
	await get_tree().physics_frame

func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	if nav_agent == null:
		return

	nav_agent.target_position = player.global_position
	var next_nav_point: Vector3 = nav_agent.get_next_path_position()
	
	# Fix 3D Navigation "jitter" by removing vertical axis from direction math
	var current_pos := global_position
	var direction: Vector3 = (next_nav_point - current_pos).normalized()

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
