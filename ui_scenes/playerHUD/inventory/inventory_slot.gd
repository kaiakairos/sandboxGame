extends Node2D

@export var slotToDisplay := 0
@export var showOutline := true

@export var isHoldSlot := false

var parent = null

func _ready():
	PlayerData.updateInventory.connect(updateDisplay)
	$Slot.visible = showOutline
	updateDisplay()
	updateSelected()
	
	if isHoldSlot:
		$button.queue_free()

func updateSelected():
	if slotToDisplay == PlayerData.selectedSlot:
		$Slot.modulate = Color(0.192,0.565,0.255)
		$Label.label_settings.outline_color = Color(0.192,0.565,0.255)
	else:
		$Slot.modulate = Color(0.082,0.114,0.157)
		$Label.label_settings.outline_color = Color(0.082,0.114,0.157)
	
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
	

func _on_color_rect_gui_input(event):
	if parent == null:
		return
	if event is InputEventMouseButton:
		if event["pressed"]:
			if event["button_index"] == 1:
				parent.clickedSlot(slotToDisplay)
			if event["button_index"] == 2:
				parent.splitSlot(slotToDisplay)
