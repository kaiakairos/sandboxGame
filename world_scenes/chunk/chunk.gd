extends Node2D

@onready var mainLayerSprite = $mainLayer
@onready var backLayerSprite = $backLayer
@onready var body = $StaticBody2D

const CHUNKSIZE :int= 8

var pos :Vector2= Vector2.ZERO

var onScreen :bool= false

var id4 :int= 0

var MUSTUPDATELIGHT :bool= false

var planet = null

func _ready():
	
	planet = get_parent().get_parent()
	
	drawData()

	id4 = (int(pos.x) % 2)+((int(pos.y) % 2)*2)
	#id4 = (pos.x % 2)+((pos.y % 4)*2)
	
	set_process(false)

func tickUpdate():
	var planetData :Array= planet.planetData
	var lightData :Array= planet.lightData
	var committedChanges := {}
	var lightChanged := false
	for x in range(CHUNKSIZE):
		for y in range(CHUNKSIZE):
			var worldPos := Vector2(x+(pos.x*CHUNKSIZE),y+(pos.y*CHUNKSIZE))
			var blockId :int= planetData[worldPos.x][worldPos.y][0]
			var blockData :Resource= BlockData.data[blockId]
			var changeDictionary :Dictionary= blockData.onTick(worldPos.x,worldPos.y,planetData,0,getBlockPosition(worldPos.x,worldPos.y))
			
			var currentLight = lightData[worldPos.x][worldPos.y]
			
			var hasPosX = [int(lightData.size() > worldPos.x + 1),int((worldPos.x - 1)>=0)]
			var hasPosY = [int(lightData.size() > worldPos.y + 1),int((worldPos.y - 1)>=0)]
			
			var lightR = lightData[worldPos.x+(1*hasPosX[0])][worldPos.y]
			var lightL = lightData[worldPos.x-(1*hasPosX[1])][worldPos.y]
			var lightB = lightData[worldPos.x][worldPos.y+(1*hasPosY[0])]
			var lightT = lightData[worldPos.x][worldPos.y-(1*hasPosY[1])]
			
			var newLight = ((lightR+lightL+lightT+lightB)/4.0)*blockData.lightMultiplier
			newLight = max(newLight,blockData.lightEmmission)
			
			lightData[worldPos.x][worldPos.y] = clamp(newLight,0.0,1.0)
			
			lightChanged = bool(max(int(abs(newLight - currentLight)>=0.001),int(lightChanged)))
			
			var toss = false
			for i in changeDictionary.keys():
				if committedChanges.has(i):
					toss = true
			if !toss:
				for i in changeDictionary.keys():
					committedChanges[i] = changeDictionary[i]
	
	MUSTUPDATELIGHT = lightChanged
	
	return committedChanges


func drawData():
	#Texture
	var img = Image.create(64,64,false,Image.FORMAT_RGBA8)
	var backImg = Image.create(64,64,false,Image.FORMAT_RGBA8)
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8,8)
	
	var planetData = planet.planetData
	clearCollisions()
	for x in range(CHUNKSIZE):
		for y in range(CHUNKSIZE):
			var imgPos = Vector2(x*8,y*8)
			var worldPos = Vector2(x+(pos.x*CHUNKSIZE),y+(pos.y*CHUNKSIZE))
			var blockSide = planet.positionLookup[x][y]
			
			##MainTile##
			var blockId = planetData[worldPos.x][worldPos.y][0]
			if ![0,7].has(blockId):
				var blockImg = BlockData.data[blockId].texture.get_image()
				blockImg.convert(Image.FORMAT_RGBA8)
				
				var shouldRotate = int(BlockData.data[blockId].rotateTextureToGravity)
				for i in range(blockSide*shouldRotate):
					blockImg.rotate_90(0)
				
				var frame = scanBlockOpen(planetData,worldPos.x,worldPos.y,0) * int(BlockData.data[blockId].connectedTexture)
				var blockRect = Rect2i(frame, 0, 8, 8)
				
				img.blend_rect(blockImg,blockRect,Vector2i(imgPos.x,imgPos.y))
			
				##Collision##
				var blockHasCollision = int(BlockData.data[blockId].hasCollision)
				if blockHasCollision:
					var collider = CollisionShape2D.new()
					collider.shape = shape
					collider.position = imgPos + Vector2(4,4)
					body.add_child(collider)
					continue
			
			##BackTile##
			var backBlockId = planetData[worldPos.x][worldPos.y][1]
			if ![0,7].has(backBlockId):
				var backBlockImg = BlockData.data[backBlockId].texture.get_image()
				backBlockImg.convert(Image.FORMAT_RGBA8)
				
				var shouldRotateBack = int(BlockData.data[backBlockId].rotateTextureToGravity)
				for i in range(blockSide*shouldRotateBack):
					backBlockImg.rotate_90(0)

				var frameB = scanBlockOpen(planetData,worldPos.x,worldPos.y,1) * int(BlockData.data[backBlockId].connectedTexture)
				var backBlockRect = Rect2i(frameB, 0, 8, 8)
				
				backImg.blend_rect(backBlockImg,backBlockRect,Vector2i(imgPos.x,imgPos.y))
			
	mainLayerSprite.texture = ImageTexture.create_from_image(img)
	backLayerSprite.texture = ImageTexture.create_from_image(backImg)

func getBlockPosition(x,y):
	return planet.positionLookup[x][y]

func scanBlockOpen(planetData,x,y,layer):
	var openL := 1
	var openR := 2
	var openT := 4
	var openB := 8
	
	openL = 1 * int(!BlockData.data[planetData[x-(1*int(x != 0))][y][layer]].texturesConnectToMe)
	openR = 2 * int(!BlockData.data[planetData[x+(1*int(x != planetData.size()-1))][y][layer]].texturesConnectToMe)
	openT = 4 * int(!BlockData.data[planetData[x][y-(1 * int(y != 0))][layer]].texturesConnectToMe)
	openB = 8 * int(!BlockData.data[planetData[x][y+(1 * int(y != planetData.size()-1))][layer]].texturesConnectToMe)
	
	return (openL+openR+openT+openB) * 8

func clearCollisions():
	for i in body.get_children():
		i.queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
	body.set_process(true)
	onScreen = true
	if !planet.visibleChunks.has(self):
		planet.visibleChunks.append(self)
	mainLayerSprite.visible = onScreen
	backLayerSprite.visible = onScreen

func _on_visible_on_screen_notifier_2d_screen_exited():
	body.set_process(false)
	onScreen = false
	planet.visibleChunks.erase(self)
	mainLayerSprite.visible = onScreen
	backLayerSprite.visible = onScreen
