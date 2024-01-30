extends CharacterBody2D

@export var system : Node2D

@onready var sprite = $Sprite
@onready var camera = $Camera2D

@onready var map = $Camera2D/SystemMap

var rotated = 0

var gravity = 1000

var previousChunk = Vector2.ZERO

var planet :Node2D = null

func _ready():
	GlobalRef.player = self
	

func _process(delta):
	if is_instance_valid(planet):
		planetMovement(delta)
	else:
		move_and_slide()
		
		if position.x < -10000:
			position.x += 20000
		if position.y < -10000:
			position.y += 20000
		if position.x > 10000:
			position.x -= 20000
		if position.y > 10000:
			position.y -= 20000
		GlobalRef.lightmap.position = global_position - Vector2(256,256)
	
	scrollBackgrounds(delta)
	
func planetMovement(delta):
	rotated = getPlanetPosition()
	sprite.rotation = lerp_angle(sprite.rotation,rotated*(PI/2),0.4)
	
	var dir = 0
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if Input.is_action_pressed("move_right"):
		dir += 1
	
	var newVel = velocity.rotated(-rotated*(PI/2))
	newVel.x = lerp(newVel.x,dir*100.0,0.2)
	newVel.y += gravity * delta
	
	newVel.y = min(newVel.y,140)
	
	if Input.is_action_pressed("jump"):
		newVel.y = -200
	if isOnFloor():
		$Camera2D.rotation = lerp_angle($Camera2D.rotation,rotated*(PI/2),0.2)

		
	velocity = newVel.rotated(rotated*(PI/2))
	
	move_and_slide()
	
	
	dig()
	updateLight()



func dig():
	
	if !is_instance_valid(planet):
		return
	
	var mousePos = planet.get_local_mouse_position()
	var tile = planet.posToTile(mousePos)
	if tile != null:
		var edit = Vector3(tile.x,tile.y,0)
		if Input.is_action_just_pressed("mouse_left"):
			planet.editTiles({edit:planet.airOrCaveAir(tile.x,tile.y)})
		if Input.is_action_just_pressed("mouse_right"):
			planet.editTiles({edit:2})
		if Input.is_action_just_pressed("inventory"):
			planet.editTiles({edit:8})

func getPlanetPosition():
	var angle1 = Vector2(1,1)
	var angle2 = Vector2(-1,1)
	
	var dot1 = int(position.dot(angle1) >= 0)
	var dot2 = int(position.dot(angle2) > 0) * 2
	
	return [0,1,3,2][dot1 + dot2]

func isOnFloor():
	
	$FloorAngles.rotation = rotated*(PI/2)
	
	if $FloorAngles/FloorCast1.is_colliding():
		return true
	if $FloorAngles/FloorCast2.is_colliding():
		return true
	return false

func updateLight():
	if !is_instance_valid(planet):
		return
	var currentChunk = Vector2(int(position.x+1024)/64,int(position.y+1024)/64)
	if previousChunk != currentChunk:
		var newPos = (currentChunk * 64) - Vector2(1024,1024) - Vector2(256,256)
		GlobalRef.lightmap.pushUpdate(planet,newPos)
	previousChunk = currentChunk

func updateLightStatic():
	if !is_instance_valid(planet):
		return
	var currentChunk = Vector2(int(position.x+1024)/64,int(position.y+1024)/64)
	var newPos = (currentChunk * 64) - Vector2(1024,1024) - Vector2(256,256)
	GlobalRef.lightmap.pushUpdate(planet,newPos)
	previousChunk = currentChunk

func scrollBackgrounds(delta):
	for layer in $Camera2D/Backgroundholder.get_children():
		layer.updatePosition(velocity.rotated(-camera.rotation)*-delta)
