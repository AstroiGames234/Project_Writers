extends Node3D
class_name Daggers

@export var damage: float = 15.0
@export var range: float = 60.0
@export var cooldown: float = 0.15  # fast spam - tune this to taste
@export var dagger_visual_scene: PackedScene

@onready var throw_point: Marker3D = $ThrowPoint
@onready var model_offset: Node3D = $ModelOffset
@onready var camera: Camera3D = get_viewport().get_camera_3d()

var can_attack: bool = true
var recoil_kick: Vector3 = Vector3.ZERO

func primary_attack() -> void:
	if not can_attack:
		return
	can_attack = false

	_do_hitscan()
	_spawn_visual_dagger()
	_kick_animation()

	await get_tree().create_timer(cooldown).timeout
	can_attack = true

func _do_hitscan() -> void:
	var space_state := camera.get_world_3d().direct_space_state
	var from := camera.global_position
	var to := from + (-camera.global_transform.basis.z * range)

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0b11  # layers: world + enemies, adjust to your setup
	query.exclude = [get_parent().get_parent().get_parent()]  # exclude player body

	var result := space_state.intersect_ray(query)

	if result:
		var hit_object = result.collider
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(damage)
		_spawn_hit_effect(result.position, result.normal, hit_object)

func _spawn_visual_dagger() -> void:
	if not dagger_visual_scene:
		return
	var dagger := dagger_visual_scene.instantiate()
	get_tree().current_scene.add_child(dagger)
	dagger.global_transform = throw_point.global_transform
	if dagger.has_method("launch"):
		dagger.launch(-camera.global_transform.basis.z, range)

func _spawn_hit_effect(pos: Vector3, normal: Vector3, hit_object: Object) -> void:
	pass  # spark/blood particles - build once basics work

func _kick_animation() -> void:
	# quick punchy offset on the model itself, separate from the sway script
	recoil_kick = Vector3(0, 0, 0.08)
	


var velocity: Vector3 = Vector3.ZERO
var speed: float = 40.0
var lifetime: float = 1.5

func launch(direction: Vector3, _range: float) -> void:
	velocity = direction.normalized() * speed
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _process(delta: float) -> void:
	global_position += velocity * delta
	# optional: add a spin
	rotate_y(delta * 10.0)
