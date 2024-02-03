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

## -1 means there will be no item
@export var itemToDrop : int = -1

var airs = [0,7]

func onTick(x,y,data,layer,dir):
	return {}

func onBreak(x,y,data,layer,dir):
	pass

func breakTile(x,y,data,layer,dir,planet):
	
	BlockData.spawnGroundItem(x,y,itemToDrop,planet)
	
	onBreak(x,y,data,layer,dir)
