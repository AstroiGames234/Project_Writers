extends Label

@export var weapon_manager: NodePath 

func _ready() -> void:
	var wm = get_node(weapon_manager)
	print("wm: ", wm)
	if wm == null:
		print("weapon_manager NodePath not set or invalid!")
		return
	wm.weapon_changed.connect(_on_weapon_changed)
	if wm.current_weapon():
		var slot = wm._current_slot()
		_on_weapon_changed(wm.current_weapon().weapon_name, slot.variant_index, slot.variants.size())

func _on_weapon_changed(weapon_name: String, variant_index: int, variant_count: int) -> void:
	print("weapon_changed fired: ", weapon_name, " ", variant_index, "/", variant_count)
	if variant_count <= 1:
		text = weapon_name
	else:
		text = "%s [%d/%d]" % [weapon_name, variant_index + 1, variant_count]
