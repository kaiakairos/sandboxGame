extends Node2D

@onready var objectContainer = $Objects
@onready var cosmicBodyContainer = $CosmicBodies

@export var rootPlanet := Node2D

func _ready():
	for planet in cosmicBodyContainer.get_children():
		planet.system = self
	for object in objectContainer.get_children():
		object.system = self
	
	GlobalRef.player.map.map(self)
	
func reparentToPlanet(object,planet):
	print(object)
	print(planet)
	if !objectContainer.get_children().has(object):
		return
	
	if object == GlobalRef.player:
		object.planet = planet
	object.reparent(planet.entityContainer)


func dumpObjectToSpace(object):
	object.reparent(objectContainer)
	if object == GlobalRef.player:
		object.planet = null
		resetObjectPositions()

func resetObjectPositions():
	var rootPosition = rootPlanet.position
	for planet in cosmicBodyContainer.get_children():
		planet.position -= rootPosition
	for object in objectContainer.get_children():
		object.position -= rootPosition
