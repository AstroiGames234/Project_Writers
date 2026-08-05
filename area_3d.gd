extends Area3D
class_name Hitbox

@export var damage: int = 50

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_node("player"):
		var player = body.get_node("player")
		if player.has_method("apply_damage"):
			player.apply_damage(damage)
