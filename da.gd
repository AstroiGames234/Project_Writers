extends Node3D

func _ready() -> void:
	DisplayServer.enable_for_stealing_focus(OS.get_process_id())
	await get_tree().process_frame
	var w := get_window()
	w.unfocusable = false
	w.set_flag(Window.FLAG_NO_FOCUS, false)
	w.grab_focus()
	print("focus:", w.has_focus())
