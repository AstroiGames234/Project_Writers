extends Area3D

@export var label: Label
@export var display_time: float = 3.0

func _ready() -> void:
	label.visible = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("get_weapon_manager"):
		_show_label()

func _show_label() -> void:
	label.visible = true
	await get_tree().create_timer(display_time).timeout
	label.visible = false
	queue_free()
