extends Block
class_name BlockLiquid

@export var harmful : bool = false

func onTick(x,y,data,layer,dir):
	var v = Vector2(0,1).rotated((PI/2)*dir)
	var targetX = clamp(x+int(v.x),0,data.size()-1)
	var targetY = clamp(y+int(v.y),0,data.size()-1)
	
	if airs.has(data[targetX][targetY][layer]):
		return {Vector3(x,y,layer):data[targetX][targetY][layer],Vector3(targetX,targetY,layer):blockId}
	v = Vector2(((randi()%2)*2)-1,0).rotated((PI/2)*dir)
	targetX = clamp(x+int(v.x),0,data.size()-1)
	targetY = clamp(y+int(v.y),0,data.size()-1)
	if airs.has(data[targetX][targetY][layer]):
		return {Vector3(x,y,layer):data[targetX][targetY][layer],Vector3(targetX,targetY,layer):blockId}
	
	return {}
