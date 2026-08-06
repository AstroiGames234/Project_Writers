extends Area3D

# Preload the enemy scene into memory
@export var enemy_scene: PackedScene = preload("res://enemy_1.tscn")
@onready var spawn_points_parent: Node3D = $"../hallway 2 markers"



func _on_body_entered(body: Node) -> void:
	# Check if the colliding object is the player
	if body.has_node("player"):
		spawn_wave()
		# Delete the trigger so it only fires once
		queue_free()
func spawn_wave() -> void:
	# Loop through all Marker3D children inside the parent node
	for marker in spawn_points_parent.get_children():
		if marker is Marker3D:
			var enemy_instance = enemy_scene.instantiate()
			
			# Add enemy to the main scene tree
			get_tree().current_scene.add_child(enemy_instance)
			
			# Match the exact global coordinates of the marker
			enemy_instance.global_position = marker.global_position
