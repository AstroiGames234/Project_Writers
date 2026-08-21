extends VBoxContainer




func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Level1.tscn")
	



func _on_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://level_2.tscn")
