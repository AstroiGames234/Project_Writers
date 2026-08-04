extends Node3D

func _ready() -> void:
	var w := get_window()
	w.unfocusable = false
	w.set_flag(Window.FLAG_NO_FOCUS, false)
	await get_tree().process_frame
	w.grab_focus()
	print("has_focus:", w.has_focus())
