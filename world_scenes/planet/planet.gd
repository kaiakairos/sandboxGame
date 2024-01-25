extends Node2D

@onready var chunkContainer = $ChunkContainer
var chunkScene = preload("res://world_scenes/chunk/chunk.tscn")

const SIZEINCHUNKS = 32 # (size * 8)^2 = number of tiles

var planetData = []
var centerPoint = Vector2.ZERO

#Noise
var noise = FastNoiseLite.new()

var tick = 0

var allChunks = []
var chunkArray2D = []

func _ready():
	generateEmptyArray()
	noise.seed = randi()
	generateTerrain()
	createChunks()

func _process(delta):
	tick += 1
	var chunksToUpdate = []
	for chunk in allChunks:
		if !chunk.onScreen:
			continue
		if tick % 4 != chunk.id4:
			continue

		var committedChanges = chunk.tickUpdate()
		for change in committedChanges.keys():
			planetData[change.x][change.y] = committedChanges[change]
			var foundChunk = chunkArray2D[change.x/8][change.y/8]
			if !chunksToUpdate.has(foundChunk):
				chunksToUpdate.append(foundChunk)
	for chunk in chunksToUpdate:
		chunk.drawData()

func generateEmptyArray():
	for x in range(SIZEINCHUNKS*8):
		planetData.append([])
		for y in range(SIZEINCHUNKS*8):
			planetData[x].append(0)
	
	centerPoint = Vector2(SIZEINCHUNKS*4,SIZEINCHUNKS*4) - Vector2(0.5,0.5)


func generateTerrain():
	for x in range(SIZEINCHUNKS*8):
		for y in range(SIZEINCHUNKS*8):
			#planetData[x][y] = getBlockPosition(x,y)
			var quad = getBlockPosition(x,y)
			var side = Vector2(x,y).rotated((PI/2)*quad).x
			var surface = (noise.get_noise_1d(side*2.0)*4.0) + (SIZEINCHUNKS*2)
			
			if getBlockDistance(x,y) <= surface:
				planetData[x][y] = 1
			elif getBlockDistance(x,y) <= surface + 4:
				planetData[x][y] = 2
			elif getBlockDistance(x,y) <= surface + 5:
				planetData[x][y] = 3
			if getBlockDistance(x,y) <= 4:
				planetData[x][y] = 4
			
			
func createChunks():
	for x in range(SIZEINCHUNKS):
		chunkArray2D.append([])
		for y in range(SIZEINCHUNKS):
			var newChunk = chunkScene.instantiate()
			newChunk.pos = Vector2(x,y)
			newChunk.position = (Vector2(x,y) * 64) - Vector2(SIZEINCHUNKS*32,SIZEINCHUNKS*32)
			chunkContainer.add_child(newChunk)
			allChunks.append(newChunk)
			chunkArray2D[x].append(newChunk)

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

func getBlockRoundedDistance(x,y):
	return (Vector2(x,y) - centerPoint).length()
