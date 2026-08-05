class_name EnemyHealth
extends Node

signal health_changed(current_health: int, max_health: int)
signal damaged(amount: int)
signal died

@export var max_health: int = 100
var current_health: int = 1

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> void:
	if current_health <= 0:
		died.emit()
	
	current_health = clampi(current_health - amount, 0, max_health)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
