extends Control

@export var fade_in_time: float = 1.0

@onready var fade_rect: ColorRect = $FadeRect 

func _ready() -> void:
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_in_time)
