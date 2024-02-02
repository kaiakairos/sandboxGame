extends Item
class_name ItemMining


func onUse(tileX:int,tileY:int,planetDir:int,planet:Planet):
	var edit = Vector3(tileX,tileY,0)
	planet.editTiles( { edit: planet.airOrCaveAir(tileX,tileY) } )
