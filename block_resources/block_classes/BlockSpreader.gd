extends Block
class_name BlockSpreader

@export var blocksCanSpreadTo :Array[int]

func onTick(x,y,data,layer,dir):
	var spwead = {}
	for i in range(4):
		var v = Vector2(0,1).rotated((PI/2)*i)
		var targetX = clamp(x+int(v.x),0,data.size()-1)
		var targetY = clamp(y+int(v.y),0,data.size()-1)
		
		if blocksCanSpreadTo.has(data[targetX][targetY][layer]):
			spwead[Vector3(targetX,targetY,layer)]=blockId
	return spwead
