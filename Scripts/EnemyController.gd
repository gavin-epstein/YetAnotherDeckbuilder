extends Node2D

var totaldifficulty = 0;
var maxdifficulty = 3;
var unitTemplate = preload("res://Unit.tscn");
var windDirection = Vector2(0,1).rotated(rand_range(0,2*PI))
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func nodeSpawned(node):
	var unitTemplateString = $UnitLibrary.getRandomEnemy(maxdifficulty - totaldifficulty,node.terrain);
	if unitTemplateString!=null:
		var unit = load(unitTemplateString).instance()
		unit.scale = Vector2(.15,.15);
		node.occupants.append(unit);
		unit.tile = node
		unit.position = node.position
		add_child(unit)
		unit.visible = true
		totaldifficulty += unit.difficulty
