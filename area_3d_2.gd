extends Area3D
class_name EnemyHurtbox

@onready var health_node = get_parent().get_node_or_null("EnemyHealth")
@onready var Hurtbox = get_parent().get_node_or_null("Hurtbox")

func apply_damage(amount: int) -> void:
	if health_node:
		health_node.take_damage(amount)
