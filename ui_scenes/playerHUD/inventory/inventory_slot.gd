extends Node2D

@export var slotToDisplay := 0

func _ready():
	PlayerData.updateInventory.connect(updateDisplay)

func updateDisplay():
	var slotInfo = PlayerData.inventory[slotToDisplay]
	var itemData = ItemData[slotInfo[0]]
	var count = slotInfo[1]
	
	$itemTexture.texture = load(itemData.texture)
	$Label.text = str(count)
	
	$Label.visible = itemData.maxStackSize != 1
