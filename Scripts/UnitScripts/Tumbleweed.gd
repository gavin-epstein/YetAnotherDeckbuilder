extends "res://Scripts/Unit.gd"


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func _ready()->void:
	onSummon()
# Called when the node enters the scene tree for the first time.

func takeTurn() ->void:
	startOfTurn()
	for i in range(3):
		pass
	endOfTurn()
