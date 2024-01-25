extends Node2D

@onready var sprite = $Sprite2D
@onready var body = $StaticBody2D

const CHUNKSIZE = 8

var pos = Vector2.ZERO

var mainSector = true
var onScreen = false

func _ready():
	createImage()
	
	mainSector = (int(pos.x) % 2)-(int(pos.y) % 2) == 0
	
	$Icon.self_modulate.r = int(mainSector)

func _process(delta):
	if onScreen:
		tickUpdate()

func tickUpdate():
	
	#Make it so it properly pushes chunk updates to itself and neighboring chunks
	#Consider passing change data to planet and having it do the updating.
	
	var planetData = get_parent().get_parent().planetData
	var committedChanges = {}
	for x in range(CHUNKSIZE):
		for y in range(CHUNKSIZE):
			var worldPos = Vector2(x+(pos.x*CHUNKSIZE),y+(pos.y*CHUNKSIZE))
			var blockId = planetData[worldPos.x][worldPos.y]
			var blockData = BlockData.data[blockId]
			var changeDictionary = blockData.onTick(worldPos.x,worldPos.y,planetData)
			
			for i in changeDictionary.keys():
				if !committedChanges.has(i):
					committedChanges[i] = changeDictionary[i]
	
	for i in committedChanges.keys():
		planetData[i.x][i.y] = committedChanges[i]
	
	if committedChanges.size() > 0:
		createImage()


func createImage():
	#Texture
	var img = Image.create(64,64,false,Image.FORMAT_RGBA8)
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8,8)
	
	var planetData = get_parent().get_parent().planetData
	clearCollisions()
	for x in range(CHUNKSIZE):
		for y in range(CHUNKSIZE):
			var worldPos = Vector2(x+(pos.x*CHUNKSIZE),y+(pos.y*CHUNKSIZE))
			var blockId = planetData[worldPos.x][worldPos.y]
			var blockImg = BlockData.data[blockId].texture.get_image()
			blockImg.convert(Image.FORMAT_RGBA8)
			
			if BlockData.data[blockId].rotateTextureToGravity:
				for i in range(getBlockPosition(worldPos.x,worldPos.y)):
					blockImg.rotate_90(0)
			
			var blockRect = Rect2i(0, 0, 8, 8)
			if BlockData.data[blockId].connectedTexture:
				var frame = scanBlockOpen(planetData,worldPos.x,worldPos.y)
				blockRect = Rect2i(frame, 0, 8, 8)
			
			var pos = Vector2(x*8,y*8)
			img.blend_rect(blockImg,blockRect,Vector2i(pos.x,pos.y))
			
			var blockHasCollision = int(BlockData.data[blockId].hasCollision)
			if blockHasCollision:
				var collider = CollisionShape2D.new()
				collider.shape = shape
				collider.position = pos + Vector2(4,4)
				body.add_child(collider)
		
	sprite.texture = ImageTexture.create_from_image(img)

func getBlockPosition(x,y):
	var angle1 = Vector2(1,1)
	var angle2 = Vector2(-1,1)
	var newPos = Vector2(x,y) - get_parent().get_parent().centerPoint
	
	var dot1 = int(newPos.dot(angle1) >= 0)
	var dot2 = int(newPos.dot(angle2) > 0) * 2
	
	return [0,1,3,2][dot1 + dot2]

func scanBlockOpen(planetData,x,y):
	var openL = 1
	var openR = 2
	var openT = 4
	var openB = 8
	
	if x != 0:
		openL = int(!BlockData.data[planetData[x-1][y]].hasCollision) * 1
	if x != planetData.size()-1:
		openR = int(!BlockData.data[planetData[x+1][y]].hasCollision) * 2
	if y != 0:
		openT = int(!BlockData.data[planetData[x][y-1]].hasCollision) * 4
	if y != planetData.size()-1:
		openB = int(!BlockData.data[planetData[x][y+1]].hasCollision) * 8
	
	return (openL+openR+openT+openB) * 8

func clearCollisions():
	for i in body.get_children():
		i.queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
	body.set_process(true)
	onScreen = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	body.set_process(false)
	onScreen = false