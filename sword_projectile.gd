extends Area3D

var speed: float = 35.0
var damage: int = 8
var direction: Vector3 = Vector3.FORWARD
var already_hit: Array[Node] = []

@export var lifetime: float = 3.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func launch(dir: Vector3, launch_speed: float, launch_damage: float) -> void:
	direction = dir.normalized()
	speed = launch_speed
	damage = launch_damage

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_area_entered(area: Area3D) -> void:
	_hit(area)

func _on_body_entered(body: Node3D) -> void:
	_hit(body)

func _hit(target: Node) -> void:
	if target in already_hit:
		return
	already_hit.append(target)

	var health_node = target
	if not health_node.has_method("take_damage"):
		health_node = target.get_node_or_null("EnemyHealth")
	if health_node == null:
		health_node = target.get_parent().get_node_or_null("EnemyHealth") if target.get_parent() else null

	if health_node and health_node.has_method("take_damage"):
		health_node.call_deferred("take_damage", damage)

	queue_free()
