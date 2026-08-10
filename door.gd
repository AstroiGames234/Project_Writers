extends Node3D

@onready var open: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await get_tree().create_timer(4.7).timeout
	open.play("open")
