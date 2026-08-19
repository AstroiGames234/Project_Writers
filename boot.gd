extends Control

@export var next_scene: PackedScene   # your main menu scene
@export var min_display_time: float = 2.0
@export var fade_out_time: float = 1.0

@onready var fade_rect: ColorRect = $FadeRect

var is_transitioning: bool = false

func _ready() -> void:
	fade_rect.modulate.a = 0.0
	await get_tree().create_timer(min_display_time).timeout
	_go_to_next_scene()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_go_to_next_scene()

func _go_to_next_scene() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_out_time)
	await tween.finished
	get_tree().change_scene_to_packed(next_scene)
