extends Area3D
class_name EnemyHurtbox2

@onready var health_node = get_parent().get_node_or_null("EnemyHealth")

func _ready() -> void:
	print("EnemyHurtbox ready, health_node: ", health_node)

func take_damage(amount: int) -> void:
	print("EnemyHurtbox.take_damage called with: ", amount)
	if health_node:
		health_node.take_damage(amount)
	else:
		print("  health_node is null!")
