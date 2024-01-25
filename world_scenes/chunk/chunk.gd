extends Node2D

@onready var sprite = $Sprite2D
@onready var body = $StaticBody2D

const CHUNKSIZE = 4

var pos = Vector2.ZERO

func _ready():
	createImage()

func createImage():
	#Texture
	var img = Image.create(32,32,false,Image.FORMAT_RGBA8)
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8,8)
	
	var planetData = get_parent().get_parent().planetData
	
	for x in range(4):
		for y in range(4):
			var worldPos = Vector2(x+(pos.x*4),y+(pos.y*4))
			var blockId = planetData[worldPos.x][worldPos.y]
			var blockImg = BlockData.data[blockId].texture.get_image()
			blockImg.convert(Image.FORMAT_RGBA8)
			
			if BlockData.data[blockId].rotateTextureToGravity:
				for i in range(getBlockPosition(worldPos.x,worldPos.y)):
					blockImg.rotate_90(0)
			
			var blockRect = Rect2i(0, 0, 8, 8)
			if BlockData.data[blockId].connectedTexture:
				var frame = scanBlockOpen(planetData,worldPos.x,worldPos.y)
				print(frame)
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
	var openL = int(!BlockData.data[planetData[x-1][y]].hasCollision) * 1
	var openR = int(!BlockData.data[planetData[x+1][y]].hasCollision) * 2
	var openT = int(!BlockData.data[planetData[x][y-1]].hasCollision) * 4
	var openB = int(!BlockData.data[planetData[x][y+1]].hasCollision) * 8
	
	return (openL+openR+openT+openB) * 8

func _on_visible_on_screen_notifier_2d_screen_entered():
	body.set_process(true)


func _on_visible_on_screen_notifier_2d_screen_exited():
	body.set_process(false)
