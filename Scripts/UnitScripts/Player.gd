extends "res://Scripts/Unit.gd"

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	onSummon()

func hasProperty(prop):
	if prop == 'any' or prop == "exists":
		return true
	elif prop == self.title:
		return true
	elif status.has(prop):
		return true
	return false
func heal(amount):
	self.health = min(maxHealth, health+amount)
	
