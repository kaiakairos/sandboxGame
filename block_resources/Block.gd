extends Resource
class_name Block

@export var blockId : int = 0

@export var texture : Texture
@export var rotateTextureToGravity : bool = false
@export var connectedTexture : bool = false
@export var texturesConnectToMe : bool = true

@export var hasCollision : bool = true


@export var lightMultiplier : float = 0.9
@export var lightEmmission : float = 0.0

var airs = [0,7]

func onTick(x,y,data,layer,dir):
	return {}
