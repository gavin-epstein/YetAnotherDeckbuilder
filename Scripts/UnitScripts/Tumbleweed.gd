extends "res://Scripts/Unit.gd"


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func _ready()->void:
	onSummon()
# Called when the node enters the scene tree for the first time.



func getNextTurn():
	var move = []
	var nextTile = tile
	for _i in range(3):
		nextTile = get_parent().map.getTileInDirection(nextTile,get_parent().windDirection )
		if nextTile.occupants.size() !=0:
			move.append(["attack",nextTile,["stab"],strength])
			move.append(["takeDamage", strength, ["crush"]])
			break
		else:
			move.append(["move",nextTile])
	self.nextTurn =  move
