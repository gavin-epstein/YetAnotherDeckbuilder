extends "res://Scripts/Unit.gd"



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
