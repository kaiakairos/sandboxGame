extends Node2D

var mapDot = preload("res://ui_scenes/map/map_dot.tscn")

func map(system):
	for obj in system.cosmicBodyContainer.get_children():
		var ins = mapDot.instantiate()
		ins.tiedNode = obj
		add_child(ins)
	for obj in system.objectContainer.get_children():
		var ins = mapDot.instantiate()
		ins.tiedNode = obj
		add_child(ins)
