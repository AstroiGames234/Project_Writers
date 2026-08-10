extends Area3D


@export var damage: int = 50


var already_hit: bool = false


func _ready() -> void:
	monitoring = false
	monitorable = false

	body_entered.connect(_on_body_entered)


func begin_attack() -> void:
	already_hit = false


func _on_body_entered(body: Node3D) -> void:
	if body.has_node("player"):
		_try_damage_body(body)


func _try_damage_body(body: Node3D) -> void:
	if already_hit:
		return

	var health_node: Node = null

	# Try the player's possible health-node names.
	health_node = body.get_node_or_null("Health")

	if health_node == null:
		health_node = body.get_node_or_null("EnemyHealth")

	if health_node != null and health_node.has_method("take_damage"):
		print("Player hit for ", damage, " damage")
		health_node.take_damage(damage)
		already_hit = true
