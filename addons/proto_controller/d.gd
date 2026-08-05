extends Node
class_name Health


signal health_changed(current_health: int, max_health: int)
signal damaged(amount: int)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	add_to_group("player_health")
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = clampi(current_health - amount, 0, max_health)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()
		get_tree().reload_current_scene()
		


func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
