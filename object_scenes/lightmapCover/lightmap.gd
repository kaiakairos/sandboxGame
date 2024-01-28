extends Node2D

@onready var sprite = $Sprite2D
var size = 64

var thread: Thread
var mutex : Mutex

var readyToGo :bool= false

var newImg = null
var newMask = null

var targetPos := Vector2.ZERO

func _ready():
	GlobalRef.lightmap = self
	#set_process(false)
	readyToGo = true

func _process(delta):
	sprite.texture = newImg
	sprite.material.set_shader_parameter("mask_texture",newMask)
	position = targetPos
	
func pushUpdate(planet,newPos):
	if !readyToGo: return
	var relativePos = (global_position - planet.global_position) + Vector2(1024,1024)
	if thread != null:
		thread.wait_to_finish()
	mutex = Mutex.new()
	thread = Thread.new()
	var newX = int(relativePos.x)/8
	var newY = int(relativePos.y)/8
	#updateLight(int(relativePos.x)/8,int(relativePos.y)/8,planet)
	thread.start(updateLight.bind(newX,newY,planet,newPos))

func updateLight(x,y,planet,newPos):
	
	if !is_instance_valid(planet):
		return
	
	var data = planet.lightData
	var blockData = planet.planetData
	
	var img = Image.create(size,size,false,Image.FORMAT_L8)
	var airImg = Image.create(size,size,false,Image.FORMAT_LA8)
	for imgX in range(size):
		for imgY in range(size):
			var l = data[x+imgX][y+imgY]
			var isAir = blockData[x+imgX][y+imgY][0] == 0 and blockData[x+imgX][y+imgY][1] == 0
			img.set_pixel(imgX,imgY,Color(l,l,l,1.0))
			airImg.set_pixel(imgX,imgY,Color(0,0,0,int(!isAir)))
			
	newImg = ImageTexture.create_from_image(img)
	newMask = ImageTexture.create_from_image(airImg)
	
	mutex.lock()
	position = newPos
	mutex.unlock()
	
	
	return
	
func _exit_tree():
	thread.wait_to_finish()
