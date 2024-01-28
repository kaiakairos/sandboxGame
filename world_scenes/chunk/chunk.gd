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
			var worldPos = Vector2(x+(pos.x*CHUNKSIZE),y+(pos.y*CHUNKSIZE))
			var blockId = planetData[worldPos.x][worldPos.y][0]
			var blockImg = BlockData.data[blockId].texture.get_image()
			blockImg.convert(Image.FORMAT_RGBA8)
			
			var backBlockId = planetData[worldPos.x][worldPos.y][1]
			var backBlockImg = BlockData.data[backBlockId].texture.get_image()
			backBlockImg.convert(Image.FORMAT_RGBA8)
			
			if BlockData.data[blockId].rotateTextureToGravity:
				for i in range(getBlockPosition(worldPos.x,worldPos.y)):
					blockImg.rotate_90(0)
			if BlockData.data[backBlockId].rotateTextureToGravity:
				for i in range(getBlockPosition(worldPos.x,worldPos.y)):
					backBlockImg.rotate_90(0)
			
			var blockRect := Rect2i(0, 0, 8, 8)
			if BlockData.data[blockId].connectedTexture:
				var frame = scanBlockOpen(planetData,worldPos.x,worldPos.y,0)
				blockRect = Rect2i(frame, 0, 8, 8)
			var backBlockRect = Rect2i(0, 0, 8, 8)
			if BlockData.data[backBlockId].connectedTexture:
				var frame = scanBlockOpen(planetData,worldPos.x,worldPos.y,1)
				backBlockRect = Rect2i(frame, 0, 8, 8)
			
			var imgPos = Vector2(x*8,y*8)
			img.blend_rect(blockImg,blockRect,Vector2i(imgPos.x,imgPos.y))
			backImg.blend_rect(backBlockImg,backBlockRect,Vector2i(imgPos.x,imgPos.y))
			
			var blockHasCollision = int(BlockData.data[blockId].hasCollision)
			if blockHasCollision:
				var collider = CollisionShape2D.new()
				collider.shape = shape
				collider.position = imgPos + Vector2(4,4)
				body.add_child(collider)
		
	mainLayerSprite.texture = ImageTexture.create_from_image(img)
	backLayerSprite.texture = ImageTexture.create_from_image(backImg)

func getBlockPosition(x,y):
	return planet.positionLookup[x][y]

func scanBlockOpen(planetData,x,y,layer):
	var openL := 1
	var openR := 2
	var openT := 4
	var openB := 8
	
	if x != 0:
		openL = int(!BlockData.data[planetData[x-1][y][layer]].texturesConnectToMe) * 1
	if x != planetData.size()-1:
		openR = int(!BlockData.data[planetData[x+1][y][layer]].texturesConnectToMe) * 2
	if y != 0:
		openT = int(!BlockData.data[planetData[x][y-1][layer]].texturesConnectToMe) * 4
	if y != planetData.size()-1:
		openB = int(!BlockData.data[planetData[x][y+1][layer]].texturesConnectToMe) * 8
	
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
