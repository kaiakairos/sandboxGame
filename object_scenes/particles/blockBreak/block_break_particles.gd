extends CPUParticles2D

var textureID = 0
var ticks = 0

func _ready():
	texture = BlockData.data[textureID].texture
	one_shot = true
	emitting = true

func _process(delta):
	ticks += 1
	if ticks > 100:
		queue_free()
