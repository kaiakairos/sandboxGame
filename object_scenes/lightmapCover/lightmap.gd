extends Node2D

@onready var sprite = $Sprite2D
var size = 64

func _ready():
	GlobalRef.lightmap = self
	set_process(false)
	
func pushUpdate(planet):
	var relativePos = (global_position - planet.global_position) + Vector2(1024,1024)
	updateLight(int(relativePos.x)/8,int(relativePos.y)/8,planet)

func updateLight(x,y,planet):
	
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
			
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.material.set_shader_parameter("mask_texture",ImageTexture.create_from_image(airImg))
