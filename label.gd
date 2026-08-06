extends Label

func _ready() -> void:
	hide()
	await get_tree().create_timer(2.5).timeout
	show()
	await get_tree().create_timer(2.5).timeout
	hide()
