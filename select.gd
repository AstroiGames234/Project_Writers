extends VBoxContainer


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial.tscn")


func _on_levle_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Level1.tscn")
