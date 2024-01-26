extends Resource
class_name Block

@export var blockId : int = 0

@export var texture : Texture
@export var rotateTextureToGravity : bool = false
@export var connectedTexture : bool = false

@export var hasCollision : bool = true
@export var testWiggle : bool = false

@export var lightMultiplier : float = 0.9
@export var lightEmmission : float = 0.0

func onTick(x,y,data,layer):
	if testWiggle:
		if data[x][y-1] == 0:
			return {Vector3(x,y,layer):0,Vector3(x,y-1,layer):blockId}
	return {}
