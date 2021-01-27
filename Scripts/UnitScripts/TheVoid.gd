extends "res://Scripts/Unit.gd"


var target;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addArmor(10)
	status["retaliate"] = true
	onSummon()


func Consume() -> void:
	var consumed = Utility.choice(tile.neighs)
	if consumed.occupants.size()>0:
		for thing in consumed.occupants:
			thing.die(self)
	gainMaxHealth(1)
	gainStrength(1)
	get_parent().map.destroyNodeAndSpawn(consumed)

func Damaged(amount,types,attacker):
	if status.has("retaliate") and amount > 0 and attacker !=null:
		attacker.takeDamage(strength,["void"],self)
