extends Node

var player : Player = null
var lightmap = null

var gravityConstant : float = 1000.0

var fastTick : float = 0.0
var globalTick : int = 0


func _physics_process(delta):
	fastTick += 1
	if fastTick >= 4:
		globalTick += 1
		fastTick = 0
