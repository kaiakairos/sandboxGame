extends Node

@onready var groundItemScene = preload("res://object_scenes/ground_item/ground_item.tscn")
@onready var blockBreakParticle = preload("res://object_scenes/particles/blockBreak/block_break_particles.tscn")

var data = {
	0:load("res://block_resources/blocks/Air.tres"),
	1:load("res://block_resources/blocks/Stone.tres"),
	2:load("res://block_resources/blocks/Dirt.tres"),
	3:load("res://block_resources/blocks/Grass.tres"),
	4:load("res://block_resources/blocks/Core.tres"),
	5:load("res://block_resources/blocks/Sand.tres"),
	6:load("res://block_resources/blocks/Torch.tres"),
	7:load("res://block_resources/blocks/CaveAir.tres"),
	8:load("res://block_resources/blocks/Water.tres"),
	9:load("res://block_resources/blocks/Lava.tres"),
}

func spawnGroundItem(tilex:int,tiley:int,id:int,planet:Planet):
	if id == -1:
		return
	var ins = groundItemScene.instantiate()
	ins.itemID = id
	ins.position = planet.tileToPos(Vector2(tilex,tiley))
	planet.entityContainer.add_child(ins)

func spawnBreakParticle(tilex:int,tiley:int,id:int,planet:Planet):
	var ins = blockBreakParticle.instantiate()
	ins.textureID = id
	ins.position = planet.tileToPos(Vector2(tilex,tiley))
	planet.entityContainer.add_child(ins)
