extends Node2D

var totaldifficulty = 0;
var maxdifficulty = 3;
var map
var units=[]
var Player
var windDirection = Vector2(0,1).rotated(rand_range(0,2*PI))
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	yield(get_parent(), "ready")
	map = get_parent().get_node("Map/MeshInstance2D")
	addPlayerAndVoid()
func nodeSpawned(node):
	var unitTemplateString = $UnitLibrary.getRandomEnemy(maxdifficulty - totaldifficulty,node.terrain);
	if unitTemplateString!=null:
		var unit = load(unitTemplateString).instance()
		addUnit(unit,node)
		totaldifficulty += unit.difficulty
func addPlayerAndVoid():
	yield(map, "mapGenerated");
	var unit  = load($UnitLibrary.getUnitByName("Void")).instance()
	unit.scale = Vector2(.15,.15);
	var node = map.voidNode
	addUnit(unit,node)
	unit = load($UnitLibrary.getUnitByName("Player")).instance()
	unit.scale = Vector2(.15,.15);
	Player = unit
	addUnit(unit, map.getRandomEmptyNode(["any"]))
func addUnit(unit, node):
	unit.scale = Vector2(.15,.15);
	node.occupants.append(unit);
	unit.tile = node
	unit.position = node.position
	add_child(unit)
	units.append(unit)
	unit.visible = true
func move(unit, node):
	unit.tile.occupants.erase(unit)
	unit.tile =  node
	node.occupants.append(unit)
