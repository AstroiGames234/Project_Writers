extends Node3D

@export var damage: int = 5
@export var attack_cooldown: float = 0.5
@export var hit_start_time: float = 0.1
@export var hit_duration: float = 0.2

@onready var hitbox: Area3D = $Hitbox

var can_attack := true
var already_hit: Array[Node] = []

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_hitbox_area_entered)

func attack() -> void:
	if not can_attack:
		return
	if is_processing_input():
		attack()
		
	
	
	
	can_attack = false
	already_hit.clear()

	await get_tree().create_timer(hit_start_time).timeout
	hitbox.monitoring = true

	await get_tree().create_timer(hit_duration).timeout
	hitbox.monitoring = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_hitbox_area_entered(body: Node3D) -> void:
	if body in already_hit:
		print("IT WORKS")
		return

	already_hit.append(body)

	if body.has_method("take_damage"):
		body.take_damage(damage)
