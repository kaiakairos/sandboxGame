extends Node2D

var planet : Planet = null
var planetDir = 0
var tileX = 0
var tileY = 0
var blockID = 0

var damage = 0

var mineMultiplier := 1.0

func _ready():
	var blockData = BlockData.data[blockID]
	$blockTexture.texture = blockData.texture
	
	if blockData.breakParticle == -1:
		$particles.texture = blockData.texture
	else:
		$particles.texture = BlockData.data[blockData.breakParticle].texture
	
	if blockData.connectedTexture:
		$blockTexture.hframes = 16
		$blockTexture.frame = scanBlockOpen(planet.planetData,tileX,tileY,0)
		$Sprite.hframes = 16
		$Sprite.frame = $blockTexture.frame
		
		
	$Sprite.texture = blockData.texture
	
func scanBlockOpen(planetData,x,y,layer):
	var openL := 1
	var openR := 2
	var openT := 4
	var openB := 8
	
	openL = 1 * int(!BlockData.data[planetData[x-(1*int(x != 0))][y][layer]].texturesConnectToMe)
	openR = 2 * int(!BlockData.data[planetData[x+(1*int(x != planetData.size()-1))][y][layer]].texturesConnectToMe)
	openT = 4 * int(!BlockData.data[planetData[x][y-(1 * int(y != 0))][layer]].texturesConnectToMe)
	openB = 8 * int(!BlockData.data[planetData[x][y+(1 * int(y != planetData.size()-1))][layer]].texturesConnectToMe)
	
	return (openL+openR+openT+openB)


func _process(delta):
	
	#this shit sucks fix it
	
	if planet == null:
		print_debug("BLOCK BREAK HAS NO PLANET ASSIGNED")
		return
	
	if Input.is_action_pressed("mouse_left"):
		var itemData = ItemData.data[PlayerData.inventory[PlayerData.selectedSlot][0]]
		if itemData is ItemMining:
			damage += delta * itemData.miningMultiplier
			var breakTime = BlockData.data[blockID].breakTime
			$blockTexture.position.x = ((randi() % 3)-1) * (damage / breakTime)
			$blockTexture.position.y = ((randi() % 3)-1) * (damage / breakTime)
			
			
			if damage >= breakTime:
				var edit = Vector3(tileX,tileY,0)
				var tileData = BlockData.data[planet.planetData[tileX][tileY][0]]
				tileData.breakTile(tileX,tileY,planet.planetData,0,planetDir,planet)
				planet.editTiles( { edit: planet.airOrCaveAir(tileX,tileY) } )
				queue_free()
		else:
			queue_free()
	else:
		queue_free()
	
	var mousePos = to_local(get_global_mouse_position())
	if abs(mousePos.y) > 4:
		queue_free()
	if abs(mousePos.x) > 4:
		queue_free()
