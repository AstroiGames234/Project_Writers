extends Node3D
signal weapon_changed(weapon_name: String, variant_index: int, variant_count: int)
# Each "slot" is a weapon archetype (e.g. Revolver) with up to 3 variant scenes
# (e.g. Revolver, Piercer, Marksman) just like ULTRAKILL's weapon variants.
class WeaponSlot:
	var variants: Array[WeaponBase] = []   # instantiated variant nodes, index 0..2
	var variant_index: int = 0

	func current() -> WeaponBase:
		if variants.is_empty():
			return null
		return variants[variant_index]

@export var starting_weapons: Array[WeaponVariantSet] = []  
var all_weapon_sets: Dictionary = {}  # weapon_name -> WeaponVariantSet, for ones not yet owned

var slots: Array[WeaponSlot] = []
var current_index: int = 0

func _ready() -> void:
	for set in starting_weapons:
		_add_slot(set)
	if slots.size() > 0:
		switch_to(0)

func _add_slot(set: WeaponVariantSet) -> void:
	var slot := WeaponSlot.new()
	for i in set.variant_scenes.size():
		var scene: PackedScene = set.variant_scenes[i]
		if scene == null:
			continue
		var w: WeaponBase = scene.instantiate()
		add_child(w)
		w.unequip()
		w.visible = false
		slot.variants.append(w)
	slots.append(slot)

func unlock_weapon(set: WeaponVariantSet) -> void:
	# call this from a pickup
	for slot in slots:
		var c := slot.current()
		if c and c.weapon_name == set.weapon_name:
			return  # already owned, don't duplicate
	_add_slot(set)
	switch_to(slots.size() - 1)  # auto-switch to newly picked up weapon

func unlock_variant(weapon_name: String, variant_index: int) -> void:
	if variant_index < 0 or variant_index > 2:
		return
	for slot in slots:
		var c := slot.current()
		if c and c.weapon_name == weapon_name:
			if variant_index < slot.variants.size():
				slot.variants[variant_index].set_meta("unlocked", true)
			return

func switch_to(index: int) -> void:
	if index < 0 or index >= slots.size():
		return
	var old_weapon := current_weapon()
	if old_weapon:
		old_weapon.unequip()
		old_weapon.visible = false
	current_index = index
	var new_weapon := current_weapon()
	if new_weapon:
		new_weapon.visible = true
		new_weapon.equip()

func switch_to_by_name(weapon_name: String) -> void:
	for i in slots.size():
		var c := slots[i].current()
		if c and c.weapon_name == weapon_name:
			switch_to(i)
			return

func next_weapon() -> void:
	switch_to((current_index + 1) % slots.size())

func prev_weapon() -> void:
	switch_to((current_index - 1 + slots.size()) % slots.size())


func cycle_variant() -> void:
	emit_signal("weapon_changed")
	var slot := _current_slot()
	if slot == null or slot.variants.size() <= 1:
		return
	var old := slot.current()
	if old:
		old.unequip()
		old.visible = false
	slot.variant_index = (slot.variant_index + 1) % slot.variants.size()
	var new_w := slot.current()
	if new_w:
		new_w.visible = true
		new_w.equip()
	
func switch_variant(variant_index: int) -> void:
	var slot := _current_slot()
	if slot == null or variant_index < 0 or variant_index >= slot.variants.size():
		return
	if variant_index == slot.variant_index:
		return
	var old := slot.current()
	if old:
		old.unequip()
		old.visible = false
	slot.variant_index = variant_index
	var new_w := slot.current()
	if new_w:
		new_w.visible = true
		new_w.equip()

func _current_slot() -> WeaponSlot:
	if slots.size() == 0:
		return null
	return slots[current_index]

func current_weapon() -> WeaponBase:
	var slot := _current_slot()
	if slot == null:
		return null
	return slot.current()

func fire_primary() -> void:
	if current_weapon():
		current_weapon().primary_attack()

func fire_secondary() -> void:
	if current_weapon():
		current_weapon().secondary_attack()
