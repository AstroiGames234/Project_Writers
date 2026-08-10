class_name EnemyHealth
extends Node


signal health_changed(current_health: int, max_health: int)
signal damaged(amount: int)
signal died


@export var max_health: int = 1

var current_health: int = 1
var is_dead: bool = false


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health = clampi(current_health - amount, 0, max_health)

	damaged.emit(amount)
	health_changed.emit(current_health, max_health)

	print("Enemy health: ", current_health)

	if current_health <= 0:
		is_dead = true
		died.emit()

		# EnemyHealth is a child of the enemy.
		get_parent().queue_free()
