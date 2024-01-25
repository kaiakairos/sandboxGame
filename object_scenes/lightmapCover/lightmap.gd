extends Node2D

var size = 48

func updateLight(x,y,data,planet):
	var img = Image.create(size,size,false,Image.FORMAT_RGB8)
	for imgX in range(size):
		for imgY in range(size):
			img.set_pixel(imgX,imgY,data[x+imgX][y+imgY])
	
	
	
	
