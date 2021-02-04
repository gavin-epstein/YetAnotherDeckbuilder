extends "res://Scripts/Unit.gd"
export var movespeed = 1


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.

func getNextTurn()->void:
	var move = []
	var nextTile = tile
	for _i in range(movespeed):
		#var towardsplayer = (get_parent().Player.tile.position -  nextTile.position).normalized()
		nextTile = get_parent().map.getTileClosestTo(nextTile, get_parent().Player.tile.position)
		if nextTile.occupants.size() !=0 and nextTile.occupants[0].hasProperty("friendly"):
			move.append(["attack",nextTile,damagetypes,strength])
			break
		else:
			move.append(["move",nextTile])
	self.nextTurn =  move
