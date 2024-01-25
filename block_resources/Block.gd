extends Resource
class_name Block

@export var blockId : int = 0

@export var texture : Texture
@export var rotateTextureToGravity : bool = false
@export var connectedTexture : bool = false

@export var hasCollision : bool = true
@export var testWiggle : bool = false


func onTick(x,y,data):
	if testWiggle:
		if data[x][y-1] == 0:
			return {Vector2(x,y):0,Vector2(x,y-1):blockId}
	return {}
