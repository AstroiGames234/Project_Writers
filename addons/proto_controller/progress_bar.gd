extends CanvasLayer

@onready var health_bar: ProgressBar = $Control/HealthBar

func _ready() -> void:
	var player_health := get_tree().get_first_node_in_group("player_health") as Health
	if player_health == null:
		push_error("player_health is null")
		return

	player_health.health_changed.connect(_on_health_changed)
	_on_health_changed(player_health.current_health, player_health.max_health)

func _on_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
