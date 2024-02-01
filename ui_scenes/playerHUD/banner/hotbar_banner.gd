extends Node2D

@onready var holdSlot = $Menu/holdingSlot



func _ready():
	#assign self to slots
	for slot in $Hotbar.get_children():
		slot.parent = self
	for slot in $Menu/InventoryBody.get_children():
		slot.parent = self
	for slot in $Menu/ArmorSlots.get_children():
		slot.parent = self
	for slot in $Menu/AccessorySlots.get_children():
		slot.parent = self

func _process(delta):
	holdSlot.position = to_local(get_global_mouse_position()) - Vector2(6,6)
