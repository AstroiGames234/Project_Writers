extends VBoxContainer

const WORLD = preload("res://Level1.tscn")



func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(WORLD)


func _on_quit_pressed() -> void:
	get_tree().quit()
