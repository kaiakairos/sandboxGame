extends Node2D

var rootNode = null
var tiedNode = null

func _process(delta):
	position = (tiedNode.global_position - rootNode.position) / 256.0
