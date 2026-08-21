extends Area3D

var speed: float = 20.0
var damage: int = 10
var direction: Vector3 = Vector3.FORWARD

@export var lifetime: float = 5.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func launch(dir: Vector3, launch_speed: float, launch_damage: float) -> void:
	direction = dir.normalized()
	speed = launch_speed
	damage = launch_damage

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	var health_node = body.get_node_or_null("Health")
	if health_node and health_node.has_method("take_damage"):
		health_node.call_deferred("take_damage", damage)

	queue_free()
