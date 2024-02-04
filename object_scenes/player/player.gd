extends CharacterBody2D
class_name Player


@export var system : Node2D

@onready var sprite = $PlayerLayers
@onready var backItem = $BackItem
@onready var animationPlayer = $AnimationPlayer
@onready var camera = $CameraOrigin/Camera2D
@onready var cameraOrigin = $CameraOrigin

@onready var map = $CameraOrigin/Camera2D/SystemMap
@onready var backgroundHolder = $CameraOrigin/Camera2D/Backgroundholder

var rotated = 0

var gravity = 1000

var previousChunk = Vector2.ZERO

var planet :Node2D = null

var animTick = 0

var maxCameraDistance := 0

var lastTileItemUsedOn := Vector2(-10,-10)

######################################################################
########################### BASIC FUNTIONS ###########################
######################################################################


func _ready():
	GlobalRef.player = self
	
	PlayerData.updateInventory.connect(setBackItemTexture)
	
	PlayerData.addItem(1,1)
	PlayerData.addItem(2,1)
	PlayerData.addItem(3,198)
	

func _process(delta):
	if is_instance_valid(planet):
		onPlanetMovement(delta)
	else:
		inSpaceMovement(delta)
		GlobalRef.lightmap.position = global_position - Vector2(256,256)
		searchForBorders()
		
		
	scrollBackgrounds(delta)
	
	if Input.is_action_pressed("mouse_left"):
		useItem()
	else:
		lastTileItemUsedOn = Vector2(-10,-10)
		$HandRoot/PlayerHand.visible = false
		$PlayerLayers/handFront.visible = true
	
######################################################################
############################## MOVEMENT ##############################
######################################################################

func onPlanetMovement(delta):
	rotated = getPlanetPosition()
	sprite.rotation = lerp_angle(sprite.rotation,rotated*(PI/2),0.4)
	$HandRoot.rotation = sprite.rotation
	
	var underCeiling = isUnderCeiling()
	var onFloor = isOnFloor()
	var speed = PlayerData.speed
	
	if underCeiling:
		speed = 25.0
		squishSprites(0.68,delta)
	else:
		squishSprites(1.0,delta)
	
	var dir = 0
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if Input.is_action_pressed("move_right"):
		dir += 1
	
	var newVel = velocity.rotated(-rotated*(PI/2))
	newVel.x = lerp(newVel.x, dir * speed, 28*delta)
	newVel.y += gravity * delta
	
	newVel.y = min(newVel.y,300)
	
	if onFloor:
		if Input.is_action_just_pressed("jump"):
			newVel.y = -275
		camera.rotation = lerp_angle(camera.rotation,rotated*(PI/2),14*delta)
	
	velocity = newVel.rotated(rotated*(PI/2))

	move_and_slide()
	
	playerAnimation(dir,newVel,delta)
	cameraMovement()
	updateLight()

func inSpaceMovement(delta):
	if system == null:
		return
	for planet in system.cosmicBodyContainer.get_children():
		var gravityConstant :float= GlobalRef.gravityConstant
		var mass :float= planet.mass
		var playerMass := 1.0
				
		var distance = planet.global_position - global_position
		var forceAmount = ((gravityConstant*mass*playerMass)/(distance.length()*distance.length()))*delta*144
				
		velocity += distance.normalized() * forceAmount

		move_and_slide()

		sprite.rotate(0.01)

func searchForBorders():
	
	var systemWidth = 65536
	
	if position.x < -(systemWidth/2):
		position.x += systemWidth
	if position.y < -(systemWidth/2):
		position.y += systemWidth
	if position.x > (systemWidth/2):
		position.x -= systemWidth
	if position.y > (systemWidth/2):
		position.y -= systemWidth
	
func cameraMovement():
	var g = to_local(get_global_mouse_position())
	
	if g.length() > maxCameraDistance:
		g = g.normalized() * maxCameraDistance
	
	cameraOrigin.position = Vector2(0,-20).rotated(camera.rotation) + (g*0.5)
	cameraOrigin.position.x = int(cameraOrigin.position.x)
	cameraOrigin.position.y = int(cameraOrigin.position.y)

######################################################################
############################## ITEMS #################################
######################################################################

func useItem():
	
	var itemData = PlayerData.getSelectedItemData()
	if itemData == null:
		$HandRoot/PlayerHand.visible = false
		$PlayerLayers/handFront.visible = true
		$HandRoot/handSwing.stop()
		return
	
	
	if Input.is_action_just_pressed("anyInventoryKey"):
		$HandRoot/handSwing.stop()
		$HandRoot/PlayerHand/itemSprite.texture = itemData.texture
		return
	
	var mousePos = planet.get_local_mouse_position()
	var tile = planet.posToTile(mousePos)
	
	if itemData != null and tile != null:
		
		if itemData.clickToUse:
			if Input.is_action_just_pressed("mouse_left"):
				itemData.onUse(tile.x,tile.y,getPlanetPosition(),planet,lastTileItemUsedOn)
				itemSwingAnimation(itemData)
		else:
			itemData.onUse(tile.x,tile.y,getPlanetPosition(),planet,lastTileItemUsedOn)
			if !$HandRoot/handSwing.is_playing():
				itemSwingAnimation(itemData)
			
		lastTileItemUsedOn = Vector2(tile.x,tile.y)

func itemSwingAnimation(itemData):
	$HandRoot/handSwing.play("swing")
	$HandRoot/PlayerHand/itemSprite.texture = itemData.texture
	$HandRoot/PlayerHand.visible = true
	$PlayerLayers/handFront.visible = false

func _on_hand_swing_animation_finished(anim_name):
	var itemData = PlayerData.getSelectedItemData()
	
	if itemData == null:
		$HandRoot/PlayerHand.visible = false
		$PlayerLayers/handFront.visible = true
		return
	
	if !itemData.clickToUse and Input.is_action_pressed("mouse_left"):
		$HandRoot/handSwing.play(anim_name)
		return
	
	$HandRoot/PlayerHand.visible = false
	$PlayerLayers/handFront.visible = true

######################################################################
############################ ANIMATION ###############################
######################################################################

func playerAnimation(dir,newVel,delta):
	#improve this later
	if dir != 0:
		sprite.scale.x = dir
		backItem.flip_h = dir == 1
		backItem.offset.x = 5.33333 * -dir
		$HandRoot.scale.x = dir
	
	backItem.visible = PlayerData.selectedSlot != 0
	
	if !isOnFloor():
		if newVel.y <= 0:
			animationPlayer.play("jump")
			return
		else:
			animationPlayer.play("fall")
			return
	if dir == 0:
		animationPlayer.play("idle")
	elif animationPlayer.current_animation != "walk":
			animationPlayer.play("walk")

func setBackItemTexture():
	backItem.texture = ItemData.data[PlayerData.inventory[0][0]].texture

func setAllPlayerFrames(frame:int):
	for obj in sprite.get_children():
		obj.frame = frame

func squishSprites(target,delta):
	for obj in sprite.get_children():
		obj.scale.y = lerp(obj.scale.y,target,20*delta)
		if obj == $PlayerLayers/eye:
			obj.scale.y = 1.0
			obj.position.y = lerp(obj.position.y,3.0+(3.0*int(target!=1.0)),20*delta)

func scrollBackgrounds(delta):
	for layer in backgroundHolder.get_children():
		layer.updatePosition(velocity.rotated(-camera.rotation)*-delta)

func scrollBackgroundsSpace(vel,delta):
	for layer in backgroundHolder.get_children():
		layer.updatePosition(vel.rotated(-camera.rotation)*-delta)

######################################################################
############################### MATHS ################################
######################################################################

func getPlanetPosition():
	var angle1 = Vector2(1,1)
	var angle2 = Vector2(-1,1)
	
	var dot1 = int(position.dot(angle1) >= 0)
	var dot2 = int(position.dot(angle2) > 0) * 2
	
	return [0,1,3,2][dot1 + dot2]

func isOnFloor():
	#improve this
	$FloorAngles.rotation = rotated*(PI/2)
	
	if $FloorAngles/FloorCast1.is_colliding():
		return true
	if $FloorAngles/FloorCast2.is_colliding():
		return true
	return false

func isUnderCeiling():
	#improve this
	$CeilingAngles.rotation = rotated*(PI/2)
	
	if $CeilingAngles/cCast1.is_colliding():
		return true
	if $CeilingAngles/cCast2.is_colliding():
		return true
	return false

######################################################################
############################# LIGHTS #################################
##################### DO NOT TOUCH !!!!!!!!!!!!#######################
######################################################################

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
