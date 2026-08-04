extends CharacterBody2D


func _on_health_health_depleted():
	queue_free()
