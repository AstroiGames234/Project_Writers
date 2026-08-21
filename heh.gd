extends Area3D

@onready var label: Label = $"../hey"

func _ready() -> void:
	label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.has_node("player"):
		label.visible = true
	




func _on_body_exited(body: Node3D) -> void:
	if body.has_node("player"):
		label.visible = false
