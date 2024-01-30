extends Node2D

@export var sprite : Texture
@export var multiplierX : float = 1.0
@export var multiplierY : float = 1.0

var mat = preload("res://ui_scenes/backgroundLayers/background_layer_material.tres")

func _ready():
	if sprite == null:
		return
	
	for i in range(4):
		var ins = Sprite2D.new()
		ins.texture = sprite
		ins.centered = false
		ins.material = mat
		ins.position.x = (i%2)*240
		ins.position.y = int(i>1)*180
		add_child(ins)

func _process(delta):
	updatePosition(Vector2(1,0))

func updatePosition(moveDir):
	position += moveDir * Vector2(multiplierX,multiplierY)
	if position.x < -240:
		position.x += 240
	if position.y < -180:
		position.y += 180
	if position.x > 0:
		position.x -= 240
	if position.y > 0:
		position.y -= 180
