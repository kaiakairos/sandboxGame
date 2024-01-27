extends Node2D

@onready var chunkContainer = $ChunkContainer
var chunkScene = preload("res://world_scenes/chunk/chunk.tscn")

const SIZEINCHUNKS = 32 # (size * 8)^2 = number of tiles

var planetData = []
var lightData = []
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

func _physics_process(delta):
	tick += 1
	var chunksToUpdate = []
	var shouldUpdateLight = 0
	for chunk in allChunks:
		if !chunk.onScreen:
			continue
		if tick % 4 != chunk.id4:
			continue

		var committedChanges = chunk.tickUpdate()
		
		shouldUpdateLight += int(chunk.MUSTUPDATELIGHT)
		chunk.MUSTUPDATELIGHT = false
		
		for change in committedChanges.keys():
			planetData[change.x][change.y][int(change.z)] = committedChanges[change]
			var foundChunk = chunkArray2D[change.x/8][change.y/8]
			if !chunksToUpdate.has(foundChunk):
				chunksToUpdate.append(foundChunk)
	
	if shouldUpdateLight > 0:
		GlobalRef.lightmap.pushUpdate(self)
	
	for chunk in chunksToUpdate:
		chunk.drawData()

func editTiles(changeCommit):
	var chunksToUpdate = []
	for change in changeCommit.keys():
		planetData[change.x][change.y][int(change.z)] = changeCommit[change]
		var foundChunk = chunkArray2D[change.x/8][change.y/8]
		if !chunksToUpdate.has(foundChunk):
			chunksToUpdate.append(foundChunk)
	for chunk in chunksToUpdate:
		chunk.drawData()

func posToTile(pos):
	var planetRadius = SIZEINCHUNKS * 32 #32 is (chunk size * tile size)/2
	var relativePos = pos + Vector2(planetRadius,planetRadius)
	var sizeInTiles = SIZEINCHUNKS * 8
	
	var tilePos = Vector2(int(relativePos.x)/8,int(relativePos.y)/8)
	if tilePos.x < 0 or tilePos.y < 0 or tilePos.x >= sizeInTiles or tilePos.y >= sizeInTiles:
		return null
	
	return tilePos
	
func generateEmptyArray():
	for x in range(SIZEINCHUNKS*8):
		planetData.append([])
		lightData.append([])
		for y in range(SIZEINCHUNKS*8):
			planetData[x].append([0,0]) # TILE LAYER, BACKGROUND LAYER
			lightData[x].append(0.0)
	
	centerPoint = Vector2(SIZEINCHUNKS*4,SIZEINCHUNKS*4) - Vector2(0.5,0.5)

func airOrCaveAir(x,y):
	var surface = SIZEINCHUNKS*2
	#Returns 7 for cave air or 0 for surface air
	return int(getBlockDistance(x,y) <= surface - 2) * 7

func generateTerrain():
	for x in range(SIZEINCHUNKS*8):
		for y in range(SIZEINCHUNKS*8):
			#planetData[x][y] = getBlockPosition(x,y)
			var quad = getBlockPosition(x,y)
			var side = Vector2(x,y).rotated((PI/2)*quad).x
			var surface = (noise.get_noise_1d(side*2.0)*4.0) + (SIZEINCHUNKS*2)
			
			if getBlockDistance(x,y) <= surface:
				planetData[x][y][0] = 1
				planetData[x][y][1] = 1
				lightData[x][y] = 0.0
			elif getBlockDistance(x,y) <= surface + 4:
				planetData[x][y][0] = 2
				planetData[x][y][1] = 2
				lightData[x][y] = 0.0
			elif getBlockDistance(x,y) <= surface + 5:
				planetData[x][y][0] = 3
				planetData[x][y][1] = 3
				lightData[x][y] = 0.0
			if getBlockDistance(x,y) <= 4:
				planetData[x][y][0] = 4
				planetData[x][y][1] = 4
				lightData[x][y] = 0.0
			
			
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
