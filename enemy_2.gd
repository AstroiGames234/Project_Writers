extends CharacterBody3D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.5
@export var projectile_speed: float = 20.0
@export var projectile_damage: int = 10

@onready var muzzle: Marker3D = $Muzzle

var player: Node3D = null
var can_fire: bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	_find_player()

func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		await get_tree().process_frame
		_find_player()

func _physics_process(delta: float) -> void:
	# apply gravity so the enemy falls to the ground on spawn (and stays grounded)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	if player == null:
		return

	var los = _has_line_of_sight()
	if can_fire and los:
		_look_at_player()
		_fire_at_player()

func _has_line_of_sight() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(muzzle.global_position, player.global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.collider.is_in_group("player")

func _look_at_player() -> void:
	var target_pos = player.global_position
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)

func _fire_at_player() -> void:
	can_fire = false
	var proj: Node3D = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_transform = muzzle.global_transform

	var direction = (player.global_position - muzzle.global_position).normalized()
	if proj.has_method("launch"):
		proj.launch(direction, projectile_speed, projectile_damage)

	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
