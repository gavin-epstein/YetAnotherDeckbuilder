extends "res://Scripts/Controller.gd"

var totaldifficulty = 0;
var maxdifficulty = 6;
var map
var cardController
var units=[]
var Player
var theVoid
var windDirection = Vector2(0,1).rotated(rand_range(0,2*PI))
var lastTargets
# Called when the node enters the scene tree for the first time.
func Load():
	yield(get_parent(),"ready")
	map = get_parent().get_node("Map/MeshInstance2D")
	cardController = get_parent().get_node("CardController")
	var step = $UnitLibrary.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	
func nodeSpawned(node):
	totaldifficulty = 0
	for unit in units:
		if unit == null:
			units.erase(unit)
	for unit in units:
		totaldifficulty += unit.difficulty
	var unit = $UnitLibrary.getRandomEnemy(maxdifficulty - totaldifficulty,node.terrain);
	if unit !=null:
		addUnit(unit,node)
func addPlayerAndVoid():
	yield(map, "mapGenerated");
	var unit  = $UnitLibrary.getUnitByName("Void")
	var node = map.voidNode
	theVoid = unit
	addUnit(unit,node)
	unit = $UnitLibrary.getUnitByName("Player")
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
	if not node.sentinel and not unit.status.has("immovable"):
		unit.tile.occupants.erase(unit)
		unit.tile =  node
		node.occupants.append(unit)
func enemyTurn():
	for unit in units:
		if unit == null:
			units.erase(unit)
	for unit in units:
		unit.startOfTurn()
	for unit in units:
		unit.Triggered("turn",[])
	for unit in units:
		unit.endOfTurn()	
func Summon(tile, unitname):
	var unit = $UnitLibrary.getUnitByName(unitname)
	print("summoning"+unit.title)
	addUnit(unit, tile)
func Attack(attacker, target):
	var damage = attacker.getStrength()
	var types = attacker.damagetypes
	var res = target.takeDamage(damage, types, attacker)
	if res is GDScriptFunctionState:
		res = yield(res, "completed")
	if res.size() > 1 and res[1] =="kill":
		attacker.Triggered("slay",[target])
func gainMaxHealth(unit,amount):
	unit.maxHealth +=amount
	unit.health += amount
	unit.updateDisplay()
func gainStrength(unit,amount):
	unit.strength+=amount
	unit.updateDisplay()
func addArmor(unit,amount):
	unit.armor+=amount
	unit.updateDisplay()
func addBlock(unit,amount):
	unit.block+=amount
	unit.updateDisplay()
func heal(unit, amount):
	unit.health = min(unit.maxHealth, unit.health+amount)
func countNames(loc, name) -> int:
	var count = 0
	for unit in units:
		if unit.hasName(name):
			count+=1
	return count
func select(targets,distance,tile):
	if targets[0] is String and targets[0] == "lastTargets":
		return lastTargets
	if tile == "Player" or tile == null:
		tile = enemyController.Player.tile
	var enemies = []
	if targets[0] is int:
		for _i in range(targets[0]):
			enemies.append(map.selectRandom(tile,distance,targets[2],targets[1]))
	elif targets[0] == "all":	
		enemies = map.selectAll(tile,distance,targets[2],targets[1])
	elif targets[0]=="splash" and targets.size >=4:
		var centers = callv("select",targets[3])
		for c in centers:
			enemies += map.selectAll(c,distance,targets[2],targets[1])
	lastTargets = enemies
	return enemies
func getTileInDirection(tile, dir1,dir2=0):
	if dir1 is Vector2:
		return map.getTileInDirection(tile, dir1)
	return map.getTileInDirection(tile, Vector2(dir1,dir2))
func MoveAndAttack(unit,target):
	var nextTile = unit.tile
	if target is Vector2:
		for _i in range(unit.speed):
			nextTile = map.getTileInDirection(nextTile,target)
			if nextTile.occupants.size() ==0:
				Action("move", [unit, nextTile])
			else:
				Action("Attack",[unit, nextTile.occupants[0]])
	else:
		var targets = map.selectAll(unit.tile,unit.sight,target,["any"])
		for _i in range(unit.speed):
			nextTile = map.getTileClosestToSet(unit.tile,targets)
			if nextTile.occupants.size() ==0:
				Action("move", [unit, nextTile])
			else:
				Action("Attack",[unit, nextTile.occupants[0]])
