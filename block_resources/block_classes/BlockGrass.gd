extends Block
class_name BlockGrass

## Chance is 1 in (int)
@export var spreadChance :int = 100
@export var blocksCanSpreadTo :Array[int]

func onTick(x,y,data,layer,dir):
	
	if randi() % spreadChance != 0:
		return {}
	var spwead = {}
	for xx in range(3):
		for yy in range(3):
			var v = Vector2(xx-1,yy-1)
			var targetX = clamp(x+int(v.x),0,data.size()-1)
			var targetY = clamp(y+int(v.y),0,data.size()-1)
			if blocksCanSpreadTo.has(data[targetX][targetY][layer]):
				for i in range(4):
					var pee = Vector2(0,1).rotated((PI/2)*i)
					var targetXX = clamp(targetX+int(pee.x),0,data.size()-1)
					var targetYY = clamp(targetY+int(pee.y),0,data.size()-1)
					if airs.has(data[targetXX][targetYY][layer]):
						spwead[Vector3(targetX,targetY,layer)]=blockId
	return spwead
