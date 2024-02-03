extends Item
class_name ItemMining

@export var miningMultiplier = 1.0

func onUse(tileX:int,tileY:int,planetDir:int,planet:Planet,lastTile:Vector2):
	
	if lastTile == Vector2(tileX,tileY):
		return
	
	var blockBreaker = load("res://object_scenes/blockBreak/block_break.tscn").instantiate()
	blockBreaker.position = planet.tileToPos(Vector2(tileX,tileY))
	blockBreaker.planet = planet
	blockBreaker.planetDir = planetDir
	blockBreaker.tileX = tileX
	blockBreaker.tileY = tileY
	blockBreaker.blockID = planet.planetData[tileX][tileY][0]
	planet.entityContainer.add_child(blockBreaker)
