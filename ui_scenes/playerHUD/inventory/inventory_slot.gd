extends Node2D

@export var slotToDisplay := 0
@export var showOutline := true

@export var isHoldSlot := false

var parent = null

func _ready():
	PlayerData.updateInventory.connect(updateDisplay)
	$Slot.visible = showOutline
	updateDisplay()
	
	if isHoldSlot:
		$Button.queue_free()
	

func updateDisplay():
	var slotInfo = PlayerData.inventory[slotToDisplay]
	
	if slotInfo[0] == -1:
		$itemTexture.texture = null
		$Label.visible = false
		return
	
	var itemData = ItemData.data[slotInfo[0]]
	var count = slotInfo[1]
	
	
	$itemTexture.texture = itemData.texture
	$Label.text = str(count)
	
	$Label.visible = itemData.maxStackSize != 1



func _on_button_pressed():
	print(slotToDisplay)
