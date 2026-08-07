extends Area3D
const WORLD = preload("res://main_menu.gd")

func _on_body_entered(body: Node) -> void:
	if body.has_node("player"):
		get_tree().change_scene_to_file("res://end_screen_1.tscn")
		
