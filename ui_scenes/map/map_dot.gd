extends Node2D

var tiedNode = null

func _process(delta):
	position = tiedNode.global_position / 128.0
