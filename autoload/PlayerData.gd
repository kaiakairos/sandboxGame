extends Node

## MOVEMENT ##
var speed = 100.0


## INVENTORY ##
# [ITEMID,COUNT]
var inventory = {} #0-39 inventory, 40-42 armor, 43-48 acces, 49 held
signal updateInventory
var selectedSlot = 0

func _ready():
	initializeInventory()

func initializeInventory():
	for i in range(50):
		inventory[i] = [-1,-1]

func addItem(itemID,amount):
	
	var itemCountLeft = amount
	
	var itemData = ItemData.data[itemID]
	var itemMax = itemData.maxStackSize
	for slot in inventoryHasItem(itemID):
		var add = inventory[slot][1] + itemCountLeft
		if add > itemMax:
			itemCountLeft -= (itemMax - inventory[slot][1])
			inventory[slot][1] = itemMax
		else:
			inventory[slot][1] += itemCountLeft
			itemCountLeft = 0
			emit_signal("updateInventory")
			return 0
	
	var emptySlot = findEmptySlot()
	if emptySlot == null:
		return itemCountLeft
	
	if itemCountLeft > itemMax:
		while itemCountLeft > itemMax:
			inventory[emptySlot] = [itemID,itemMax]
			itemCountLeft -= itemMax
			emptySlot = findEmptySlot()
			if emptySlot == null:
				return itemCountLeft
	
	inventory[emptySlot] = [itemID,itemCountLeft]
	
	emit_signal("updateInventory")
	return 0
	

func findEmptySlot():
	for i in range(40):
		if inventory[i][0] == -1:
			return i
	return null

func inventoryHasItem(itemID):
	var slots = []
	for i in range(50):
		if inventory[i][0] == itemID:
			slots.append(i)
	return slots

func swapItem(slot1,slot2):
	var carry = inventory[slot1].duplicate()
	inventory[slot1] = inventory[slot2]
	inventory[slot2] = carry
	emit_signal("updateInventory")
	

func getSelectedItemData():
	return ItemData.data[inventory[selectedSlot][0]]

func consumeSelected():
	inventory[selectedSlot][1] -= 1
	if inventory[selectedSlot][1] <= 0:
		inventory[selectedSlot] = [-1,-1]
	emit_signal("updateInventory")

