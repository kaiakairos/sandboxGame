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

## -1 will match current block ID
@export var breakParticle : int = -1

## time in seconds to break
@export var breakTime : float = 0.5

var airs = [0,7]

func onTick(x,y,data,layer,dir):
	return {}

func onBreak(x,y,data,layer,dir):
	pass

func breakTile(x,y,data,layer,dir,planet):
	
	BlockData.spawnGroundItem(x,y,itemToDrop,planet)
	if breakParticle == -1:
		BlockData.spawnBreakParticle(x,y,blockId,planet)
	else:
		BlockData.spawnBreakParticle(x,y,breakParticle,planet)
	
	onBreak(x,y,data,layer,dir)
