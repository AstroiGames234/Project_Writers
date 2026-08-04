extends Area3D
class_name Hurtbox3D

@onready var health := get_parent().get_node_or_null("Health") as Health

func apply_damage(amount: int) -> void:
	if health != null:
		health.take_damage(amount)
