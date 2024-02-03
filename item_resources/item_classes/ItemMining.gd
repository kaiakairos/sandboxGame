extends Item
class_name ItemMining


func onUse(tileX:int,tileY:int,planetDir:int,planet:Planet):
	var edit = Vector3(tileX,tileY,0)
	
	var tileData = BlockData.data[planet.planetData[tileX][tileY][0]]
	tileData.breakTile(tileX,tileY,planet.planetData,0,planetDir,planet)
	
	planet.editTiles( { edit: planet.airOrCaveAir(tileX,tileY) } )
