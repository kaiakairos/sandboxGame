extends Item
class_name ItemBlock

@export var blockID := 0


func onUse(tileX:int,tileY:int,planetDir:int,planet:Planet,lastTile:Vector2):
	
	if planet == null:
		#Cancel if not on planet
		return "failure"
	
	var planetData = planet.planetData
	
	if ![0,7].has(planetData[tileX][tileY][0]):
		#Cancel is target tile isn't empty
		return "failure"
	
	if ![0,7].has(planetData[tileX][tileY][1]):
		#Succeed if wall tile exists
		var edit = Vector3(tileX,tileY,0)
		planet.editTiles({edit:blockID})
		PlayerData.consumeSelected()
		return "success"
	
	for i in range(4):
		#Search neighboring tiles
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
