class_name WeaponBaseLunge
extends Node3D

@export var weapon_name: String = "Unnamed"
@export var is_melee: bool = true
var secondary_uses_dash: bool = true

func equip() -> void:
	visible = true
	# play a draw animation, reset state, etc.

func unequip() -> void:
	visible = false

func primary_attack() -> void:
	pass # override in each weapon script

func secondary_attack() -> void:
	pass # override, e.g. for parry/block/aim
	
