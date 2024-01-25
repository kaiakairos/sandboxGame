extends Node2D

@onready var chunkContainer = $ChunkContainer
var chunkScene = preload("res://world_scenes/chunk/chunk.tscn")

const SIZEINCHUNKS = 32 # (size * 4)^2 = number of tiles


var planetData = []
var centerPoint = Vector2.ZERO

func _ready():
	generateEmptyArray()
	
	generateTerrain()
	createChunks()



func generateEmptyArray():
	for x in range(SIZEINCHUNKS*4):
		planetData.append([])
		for y in range(SIZEINCHUNKS*4):
			planetData[x].append(0)
	
	centerPoint = Vector2(SIZEINCHUNKS*2,SIZEINCHUNKS*2) - Vector2(0.5,0.5)
	
func generateTerrain():
	for x in range(SIZEINCHUNKS*4):
		for y in range(SIZEINCHUNKS*4):
			#planetData[x][y] = getBlockPosition(x,y)
			
			if getBlockDistance(x,y) <= 37:
				planetData[x][y] = 3
			
			if getBlockDistance(x,y) <= 36:
				planetData[x][y] = 2
			
			if getBlockDistance(x,y) <= 32:
				planetData[x][y] = 1
			
			if getBlockDistance(x,y) <= 2:
				planetData[x][y] = 4

func createChunks():
	for x in range(SIZEINCHUNKS):
		for y in range(SIZEINCHUNKS):
			var newChunk = chunkScene.instantiate()
			newChunk.pos = Vector2(x,y)
			newChunk.position = (Vector2(x,y) * 32) - Vector2(SIZEINCHUNKS*16,SIZEINCHUNKS*16)
			chunkContainer.add_child(newChunk)

func getBlockPosition(x,y):
	var angle1 = Vector2(1,1)
	var angle2 = Vector2(-1,1)
	var newPos = Vector2(x,y) - centerPoint
	
	var dot1 = int(newPos.dot(angle1) >= 0)
	var dot2 = int(newPos.dot(angle2) > 0) * 2
	
	return [0,1,3,2][dot1 + dot2]

func getBlockDistance(x,y):
	var quadtrant = getBlockPosition(x,y)
	var newPos = Vector2(x,y) - centerPoint
	newPos = newPos.rotated((PI/2)*-quadtrant)
	return -newPos.y

