extends Item
class_name ItemBlock

@export var blockID := 0


func onUse(tileX:int,tileY:int,planetDir:int,planet:Planet):
	
	if planet == null:
		return
	
	var planetData = planet.planetData
	for i in range(4):
		var s = Vector2(1,0).rotated((PI/2)*i)
		var tile = Vector2(tileX,tileY) + Vector2(int(s.x),int(s.y))
		if tile.x < 0 or tile.x >= planetData.size() or tile.x < 0 or tile.x >= planetData.size():
			continue
		if ![0,7].has(planetData[tile.x][tile.y][0]):
			var edit = Vector3(tileX,tileY,0)
			planet.editTiles({edit:blockID})
			PlayerData.consumeSelected()
			return "success"
	return "failure"
