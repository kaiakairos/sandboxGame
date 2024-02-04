extends CharacterBody2D
class_name GroundItem

@onready var texture = $textureRoot/texture
@onready var back = $textureRoot/back

@onready var tint = $textureRoot/texture/tint

var rotSide = 0

var gravity = 600

var itemID = 0
var amount = 1
var maxAmount = 99

var ticks = 0

var tweening = false

func _ready():
	var itemData = ItemData.data[itemID]
	texture.texture = itemData.texture
	maxAmount = itemData.maxStackSize
	
	var randVelocity = Vector2(randi_range(-70,70),-60)
	rotSide = getPlanetPosition()
	velocity = randVelocity.rotated(rotSide*(PI/2))
	
	determineAmount()
	
func _process(delta):
	
	if tweening:
		return
	
	ticks += 1
	rotSide = getPlanetPosition()
	
	var newVelocity = velocity.rotated(-rotSide*(PI/2))
	newVelocity.x = lerp(newVelocity.x,0.0,10.0*delta)
	newVelocity.y += gravity * delta
	newVelocity.y = min(newVelocity.y,150)
	velocity = newVelocity.rotated(rotSide*(PI/2))
	
	move_and_slide()
	
	$textureRoot.rotation = rotSide*(PI/2)
	
	texture.offset.y = (sin(ticks*0.12) * 2.0) - 2
	back.offset.y = texture.offset.y
	
func getPlanetPosition():
	var angle1 = Vector2(1,1)
	var angle2 = Vector2(-1,1)
	
	var dot1 = int(position.dot(angle1) >= 0)
	var dot2 = int(position.dot(angle2) > 0) * 2
	
	return [0,1,3,2][dot1 + dot2]

func _on_area_2d_body_entered(body):
	
	if tweening:
		return
	
	
	tweenAndDestroy(body.position,true)


func _on_stack_body_entered(body):
	
	if tweening or body == self:
		return

	if body is GroundItem:
		if body.itemID != itemID or body.tweening:
			return
		if body.ticks > ticks:
			if amount + body.amount > maxAmount: return
			amount += body.amount
			determineAmount()
			body.tweenAndDestroy(position,false)
			return

func determineAmount():
	if amount > 1:
		tint.color.a = (amount - 1) * 0.05

func tweenAndDestroy(pos,shouldAddItem):
	if tweening:
		return
	tweening = true
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",pos,0.1)
	await tween.finished
	
	if shouldAddItem:
		if PlayerData.addItem(itemID,amount) == 0:
			queue_free()
	else:
		queue_free()
