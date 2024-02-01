extends Node2D

@onready var holdSlot = $holdingSlot

var invOpen = false

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
	if Input.is_action_just_pressed("inventory"):
		invOpen = !invOpen
		$Menu.visible = invOpen
	
	if Input.is_action_just_pressed("scroll_up"):
		PlayerData.selectedSlot -= 1
		if PlayerData.selectedSlot < 0:
			PlayerData.selectedSlot = 9
		for slot in $Hotbar.get_children():
			slot.updateSelected()
	if Input.is_action_just_pressed("scroll_down"):
		PlayerData.selectedSlot += 1
		if PlayerData.selectedSlot > 9:
			PlayerData.selectedSlot = 0
		for slot in $Hotbar.get_children():
			slot.updateSelected()
	
func clickedSlot(slot):
	if PlayerData.inventory[49][0] == -1:
		PlayerData.swapItem(slot,49)
		return
	elif PlayerData.inventory[slot][0] == -1:
		PlayerData.swapItem(slot,49)
		return
	elif PlayerData.inventory[slot][0] != PlayerData.inventory[49][0]:
		PlayerData.swapItem(slot,49)
		return
	else:
		var maxStack = ItemData.data[PlayerData.inventory[slot][0]].maxStackSize
		var total = PlayerData.inventory[slot][1] + PlayerData.inventory[49][1]
		if total <= maxStack:
			PlayerData.inventory[slot][1] = total
			PlayerData.inventory[49] = [-1,-1]
		else:
			PlayerData.inventory[slot][1] = maxStack
			PlayerData.inventory[49][1] = total - maxStack 
		PlayerData.emit_signal("updateInventory")

func splitSlot(slot):
	#If Hand slot is empty
	if PlayerData.inventory[49][0] == -1:
		var amount = PlayerData.inventory[slot][1]
		var half = PlayerData.inventory[slot][1] / 2
		if amount <= 1:
			return
		
		PlayerData.inventory[slot][1] = half
		PlayerData.inventory[49] = [PlayerData.inventory[slot][0],amount-half]
		PlayerData.emit_signal("updateInventory")
		return
	#If placement slot is empty
	elif PlayerData.inventory[slot][0] == -1:
		PlayerData.inventory[slot] = [PlayerData.inventory[49][0],1]
		PlayerData.inventory[49][1] -= 1
		if PlayerData.inventory[49][1] <= 0:
			PlayerData.inventory[49] = [-1,-1]
		PlayerData.emit_signal("updateInventory")
		return
	#If neither are empty but they aren't the same item type
	elif PlayerData.inventory[slot][0] != PlayerData.inventory[49][0]:
		return
	#If neither are empty but they ARE the same item type
	else:
		var maxStack = ItemData.data[PlayerData.inventory[slot][0]].maxStackSize
		
		if PlayerData.inventory[slot][1] >= maxStack:
			return
		
		PlayerData.inventory[slot][1] += 1
		
		PlayerData.inventory[49][1] -= 1
		if PlayerData.inventory[49][1] <= 0:
			PlayerData.inventory[49] = [-1,-1]
		PlayerData.emit_signal("updateInventory")
		return
		
		
		
