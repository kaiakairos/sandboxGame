extends Node2D

@onready var sprite = $Sprite2D
var size = 64

var thread: Thread

var readyToGo :bool= false

var newImg = null
var newMask = null

func _ready():
	GlobalRef.lightmap = self
	set_process(false)
	readyToGo = true

func _process(delta):
	sprite.texture = newImg
	sprite.material.set_shader_parameter("mask_texture",newMask)
	
func pushUpdate(planet,newPos):
	if !readyToGo: return
	if thread != null:
		if thread.is_alive():
			return
	var relativePos = (newPos - planet.global_position) + Vector2(1024,1024)
	thread = Thread.new()
	var newX = int(relativePos.x)/8
	var newY = int(relativePos.y)/8
	#updateLight(int(relativePos.x)/8,int(relativePos.y)/8,planet)
	thread.start(updateLight.bind(newX,newY,planet,newPos))
	thread.wait_to_finish()
	position = newPos
	sprite.texture = newImg
	sprite.material.set_shader_parameter("mask_texture",newMask)
	
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
	
	return
	
func _exit_tree():
	thread.wait_to_finish()
