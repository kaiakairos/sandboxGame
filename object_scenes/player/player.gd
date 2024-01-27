extends CharacterBody2D

@onready var sprite = $Sprite

var rotated = 0

var gravity = 1000

var previousChunk = Vector2.ZERO

func _ready():
	GlobalRef.player = self

func _process(delta):
	
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
	
	if isOnFloor():
		if Input.is_action_pressed("jump"):
			newVel.y = -200
		$Camera2D.rotation = lerp_angle($Camera2D.rotation,rotated*(PI/2),0.2)
		
		
	velocity = newVel.rotated(rotated*(PI/2))
	
	move_and_slide()
	
	
	dig()
	updateLight()

func dig():
	var mousePos = get_parent().get_local_mouse_position()
	var tile = get_parent().posToTile(mousePos)
	if tile != null:
		var edit = Vector3(tile.x,tile.y,0)
		if Input.is_action_just_pressed("mouse_left"):
			get_parent().editTiles({edit:get_parent().airOrCaveAir(tile.x,tile.y)})
		if Input.is_action_just_pressed("mouse_right"):
			get_parent().editTiles({edit:9})
		if Input.is_action_just_pressed("inventory"):
			get_parent().editTiles({edit:8})

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
	var currentChunk = Vector2(int(position.x+1024)/64,int(position.y+1024)/64)
	if previousChunk != currentChunk:
		$Lightmap.position = (currentChunk * 64) - Vector2(1024,1024) - Vector2(256,256)
		GlobalRef.lightmap.pushUpdate(get_parent())
	previousChunk = currentChunk
