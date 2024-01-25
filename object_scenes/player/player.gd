extends CharacterBody2D

@onready var sprite = $Sprite

var rotated = 0

var gravity = 1000

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
