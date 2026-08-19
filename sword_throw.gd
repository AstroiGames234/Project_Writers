extends WeaponBase
class_name SwordThrow

@export var damage: int = 5
@export var attack_cooldown: float = 0.5
@export var hit_start_time: float = 0.1
@export var hit_duration: float = 0.2

@export var throw_projectile_scene: PackedScene   
@export var throw_speed: float = 35.0
@export var throw_damage: int = 8
@export var throw_cooldown: float = 1.0

@onready var hitbox: Area3D = $Hitbox
@onready var hitbox_shape: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var anim_player: AnimationPlayer = $AttackAnimation
@onready var muzzle: Marker3D = $Muzzle        
@onready var mesh: Node3D = $MeshInstance3D          

var can_attack: bool = true
var can_throw: bool = true
var already_hit: Array[Node] = []

func _ready() -> void:
	weapon_name = "Sword"  
	is_melee = true
	secondary_uses_dash = false
	
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	

func primary_attack() -> void:
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


func secondary_attack() -> void:
	if not can_throw:
		return
	if throw_projectile_scene == null:
		push_warning("SwordThrow: throw_projectile_scene not assigned")
		return
	can_throw = false


	if mesh:
		mesh.visible = false  

	var proj: Node3D = throw_projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_transform = muzzle.global_transform
	if proj.has_method("launch"):
		proj.launch(-muzzle.global_transform.basis.z, throw_speed, throw_damage)

	await get_tree().create_timer(throw_cooldown).timeout
	if mesh:
		mesh.visible = true
	can_throw = true

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
