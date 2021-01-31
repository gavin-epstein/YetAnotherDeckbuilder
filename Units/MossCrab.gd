extends "res://Scripts/UnitScripts/BasicPursue.gd"


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.title = "Moss Crab"
	self.status.lifelink = true
	var crabcount = 0
	for unit in get_parent().units:
		if unit.title == "Moss Crab":
			crabcount+=1
	print("crabcount: "+str(crabcount))
	if crabcount%2 ==0:
		for other in tile.neighs:
			if !other.sentinel and other.occupants.size==0:
				get_parent().summon(other, "Moss Crab")
				break
