extends Node3D

@export var damage: int = 5
@export var attack_cooldown: float = 0.5
@export var hit_start_time: float = 0.1
@export var hit_duration: float = 0.2

@onready var hitbox: Area3D = $Hitbox
@onready var hitbox_shape: CollisionShape3D = $Hitbox/CollisionShape3D

var can_attack: bool = true
var already_hit: Array[Node] = []

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	print("Enemy spawned")

	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func attack() -> void:
	if not can_attack:
		return

	can_attack = false
	already_hit.clear()

	await get_tree().create_timer(hit_start_time).timeout
	hitbox_shape.disabled = false
	hitbox.monitoring = true
	hitbox.monitorable = true

	await get_tree().create_timer(hit_duration).timeout
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area in already_hit:
		return
	already_hit.append(area)

	if area.has_method("take_damage"):
		area.take_damage(damage)

func _on_hitbox_body_entered(body: Node3D) -> void:
	if not is_instance_valid(body):
		return
	if body in already_hit:
		return

	already_hit.append(body)

	if body.has_method("take_damage"):
		body.call_deferred("take_damage", damage)
