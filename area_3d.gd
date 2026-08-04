extends Area3D
class_name Hitbox

@export var damage: int = 50

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_node("Hurtbox"):
		var hurtbox = body.get_node("Hurtbox")
		if hurtbox.has_method("apply_damage"):
			hurtbox.apply_damage(damage)

func _on_area_entered(area: Area3D) -> void:
	if area.has_method("apply_damage"):
		area.apply_damage(damage)
