extends Area3D

# Preload the enemy scene into memory
@export var enemy_scene: PackedScene = preload("res://enemy_1.tscn")

func _on_body_entered(body: Node) -> void:
	# Check if the colliding object is the player
	if body.has_node("player"):
		spawn_enemy()
		# Delete the trigger so it only fires once
		queue_free()

func spawn_enemy() -> void:
	# 1. Create a new instance of the enemy
	var enemy = enemy_scene.instantiate()
	
	# 2. Set the enemy's position (e.g., at the trigger's position)
	enemy.global_position = global_position
	
	# 3. Add the enemy to the active scene tree
	get_parent().add_child(enemy)
