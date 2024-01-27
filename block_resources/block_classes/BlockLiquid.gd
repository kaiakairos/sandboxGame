extends Block
class_name BlockLiquid

@export var harmful : bool = false

func onTick(x,y,data,layer,dir):
	var v = Vector2(0,1).rotated((PI/2)*dir)
	if airs.has(data[x+int(v.x)][y+int(v.y)][layer]):
		return {Vector3(x,y,layer):data[x+int(v.x)][y+int(v.y)][layer],Vector3(x+int(v.x),y+int(v.y),layer):blockId}
	v = Vector2(((randi()%2)*2)-1,0).rotated((PI/2)*dir)
	if airs.has(data[x+int(v.x)][y+int(v.y)][layer]):
		return {Vector3(x,y,layer):data[x+int(v.x)][y+int(v.y)][layer],Vector3(x+int(v.x),y+int(v.y),layer):blockId}
	
	return {}
