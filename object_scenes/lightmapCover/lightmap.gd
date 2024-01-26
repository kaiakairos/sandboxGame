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
	
	var img = Image.create(size,size,false,Image.FORMAT_L8)
	for imgX in range(size):
		for imgY in range(size):
			var l = data[x+imgX][y+imgY]
			img.set_pixel(imgX,imgY,Color(l,l,l,1.0))
	
	sprite.texture = ImageTexture.create_from_image(img)
	
