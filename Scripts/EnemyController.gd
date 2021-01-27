extends Node2D

var totaldifficulty = 0;
var maxdifficulty = 3;
var map
var units=[]
var Player
var theVoid
var windDirection = Vector2(0,1).rotated(rand_range(0,2*PI))
# Called when the node enters the scene tree for the first time.
func Load():
	yield(get_parent(),"ready")
	map = get_parent().get_node("Map/MeshInstance2D")
	var step = $UnitLibrary.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	
func nodeSpawned(node):
	totaldifficulty = 0
	for unit in units:
		totaldifficulty += unit.difficulty
	var unitTemplateString = $UnitLibrary.getRandomEnemy(maxdifficulty - totaldifficulty,node.terrain);
	if unitTemplateString!=null:
		var unit = load(unitTemplateString).instance()
		addUnit(unit,node)
		totaldifficulty += unit.difficulty
func addPlayerAndVoid():
	yield(map, "mapGenerated");
	var unit  = load($UnitLibrary.getUnitByName("Void")).instance()
	var node = map.voidNode
	theVoid = unit
	addUnit(unit,node)
	unit = load($UnitLibrary.getUnitByName("Player")).instance()
	Player = unit
	addUnit(unit, map.getRandomEmptyNode(["any"]))
	units.erase(Player)
func addUnit(unit, node):
	unit.scale = Vector2(.15,.15);
	node.occupants.append(unit);
	unit.tile = node
	unit.position = node.position
	add_child(unit)
	units.append(unit)
	unit.visible = true
func move(unit, node):
	if not node.sentinel:
		unit.tile.occupants.erase(unit)
		unit.tile =  node
		node.occupants.append(unit)

func enemyTurn():
	for unit in units:
		unit.getNextTurn()
		unit.startOfTurn()
	for unit in units:
		unit.takeTurn()
	for unit in units:
		unit.endOfTurn()	
	
