extends "res://Scripts/Controller.gd"

var totaldifficulty = 0;
var maxdifficulty = 6;
var map
var units=[]
var Player
var theVoid
var windDirection = Vector2(0,1).rotated(rand_range(0,2*PI))
var lastTargets
var voidNext
const unitscale=Vector2(.17,.17)
# Called when the node enters the scene tree for the first time.
func Load(parent):
	#yield(parent,"ready")
	map = parent.map
	cardController = parent.cardController
	enemyController=self
	var step = $UnitLibrary.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
func countDifficulty():
	totaldifficulty = 0
	for _i in units.count(null):
		units.erase(null)
	for unit in units:
		if unit!=null:
			totaldifficulty += unit.difficulty

func nodeSpawned(node):
	countDifficulty()
	var unit = $UnitLibrary.getRandomEnemy(maxdifficulty - totaldifficulty,node.terrain);
	if unit !=null:
		addUnit(unit,node)
func addPlayerAndVoid():
	yield(map, "mapGenerated");
	var unit  = $UnitLibrary.getUnitByName("Void")
	var node = map.voidNode
	theVoid = unit
	addUnit(unit,node)
	unit = $UnitLibrary.getUnitByName("Mora")
	Player = unit
	addUnit(unit, map.getRandomEmptyNode(["any"]))
	units.erase(Player)
	pickConsumed()
func addUnit(unit, node,head=null):
	if head == null:
		head = unit
	if node == null:
		return false
	unit.scale = unitscale;
	if not unit.trap:
		node.occupants.append(unit);
	unit.tile = node
	unit.position = node.position
	add_child(unit)
	unit.onSummon(head)
	units.append(unit)
	if unit.componentnames.size()>0:
		for link in unit.linkagenames:
			var linkname = link[0]
			var start = int(link[1])
			var end = int(link[2])
			
			if unit.components[start] == null:
				assert(false, "Malformed unit")
			if unit.components[end] == null:
				#Spawn new component
				var basetile = unit.components[start].tile
				var tile = map.selectRandom(basetile,1,"empty",["any"])
				if tile == null:
					unit.difficulty = 0
					unit.die(null)
					print("Unit didn't fit")
					return
				var component = $UnitLibrary.getUnitByName(unit.componentnames[end])
				add_child(component)
				component.scale = unitscale
				if not component.trap:
					tile.occupants.append(component)
				component.position = tile.position
				component.onSummon(unit)
				component.controller = self
				component.tile = tile
				unit.components[end] = component
			#Spawn new linkage
			var linkage = $UnitLibrary.getLinkageByName(linkname)
			linkage.setup(unit.components[start],unit.components[end],head)
			add_child(linkage)
			unit.links.append(linkage)
	
func swap(unit1,unit2):
	if move(unit1,unit2.tile):
		move(unit2,unit1.tile)
	
func move(unit, node):
	if unit == null or node ==null:
		return false
	if node is Array:
		if node.size() ==0:
			return false
		else:
			node = node[0]
	if unit ==null or node == null:
		return false
	unit.facing((node.position - unit.position).angle())
	if not node.sentinel and not unit.status.has("immovable"):
		unit.tile.occupants.erase(unit)
		unit.tile =  node
		if not unit.trap:
			node.occupants.append(unit)
func enemyTurn():
	for unit in units:
		if unit == null:
			units.erase(unit)
		elif unit.health <0:
			unit.die(null)
	for unit in units:
		unit.startOfTurn()
	for unit in units:
		if unit != null and not unit.skipturn:
			unit.Triggered("turn",[])
			yield(get_tree().create_timer(.1), "timeout")
	for unit in units:
		if unit != null:
			unit.endOfTurn()	
	countDifficulty()
	if totaldifficulty < 1 or totaldifficulty < .2* maxdifficulty:
		cardController.Action("consume",[])
func Summon(tile, unitname):
	if tile ==null:
		return false
	var tiles
	if not tile is Array:
		tiles = [tile]
	else:
		tiles= tile
	
	for tile in tiles:
		var empty = true
		for other in units:
			if other.tile== tile:
				empty = false
		if empty:
			var unit = $UnitLibrary.getUnitByName(unitname)		
			addUnit(unit, tile)
func Attack(attacker, target):
	attacker = attacker.head
	if target  == null:
		return false
	
	if target  == null:
		return false
	if not target.has_method("isUnit"):
		if target.occupants.size() ==0:
			return false
		target= target.occupants[0]
	target = target.get("head")
	attacker.facing((target.position - attacker.position).angle())
	target.facing((attacker.position - target.position).angle())
	var damage = attacker.getStrength()
	var types = attacker.damagetypes
	attacker.playAnimation("attack")
	target.playAnimation("defend")
	var res = target.takeDamage(damage, types, attacker)
	if res is GDScriptFunctionState:
		res = yield(res, "completed")
	if res.size() > 1 and res[1] =="kill":
		attacker.Triggered("slay",[target])
func gainMaxHealth(unit,amount):
	var units
	if not unit is Array:
		units = [unit]
	else:
		units= unit
	for unit in units:
		unit.maxHealth +=amount
		unit.changeHealth(amount)
		unit.updateDisplay()
func gainStrength(unit,amount):
	var units
	if not unit is Array:
		units = [unit]
	else:
		units= unit
	for unit in units:
		if unit.get("occupants")!=null:
			if unit.occupants.size()>0:
				unit = unit.occupants[0]
			else:
				continue		
		unit.strength+=amount
		unit.updateDisplay()
	return true
func addArmor(unit,amount):
	var units
	if not unit is Array:
		units = [unit]
	else:
		units= unit
	for unit in units:
		if unit.has_method("isUnit"):
			unit.armor+=amount
			unit.updateDisplay()
		elif unit.occupants.size() > 0:
			unit = unit.occupants[0]
			unit.armor+=amount
			unit.updateDisplay()
func addBlock(unit,amount):
	if unit ==null:
		return false
	var units
	if not unit is Array:
		units = [unit]
	else:
		units= unit
	for unit in units:
		if !unit.has_method("isUnit") and unit.occupants.size() > 0:
			unit = unit.occupants[0]
		unit.block+=amount
		unit.get_node("Audio").playsound("block")
		unit.updateDisplay()
func heal(unit, amount):
	if unit ==null:
		return false
	var units
	if not unit is Array:
		units = [unit]
	else:
		units= unit
	for unit in units:
		amount = min(amount,unit.maxHealth - unit.health )
		unit.changeHealth(amount)	
func countNames(loc, name) -> int:
	var count = 0
	for unit in units:
		if unit == null:
			units.erase(unit)
			continue
		if unit.hasName(name):
			count+=1
	return count

func select(targets,distance,tile):
	if targets[0] is String and targets[0] == "lastTargets":
		return lastTargets
	if (tile is String and tile == "Player") or tile == null:
		tile = enemyController.Player.tile
	var enemies = []
	if targets[0] is int:
		for _i in range(targets[0]):
			enemies.append(map.selectRandom(tile,distance,targets[2],targets[1]))
	elif targets[0] == "all":	
		enemies = map.selectAll(tile,distance,targets[2],targets[1])
	elif targets[0]=="splash" and targets.size() >=4:
		var centers = callv("select",targets[3])
		for c in centers:
			enemies += map.selectAll(c,distance,targets[2],targets[1])
	lastTargets = enemies
	return enemies #was enemies[0], but I'm pretty sure it should be an array right?
func getTileInDirection(tile, dir1,dir2=0):
	if dir1 is Vector2:
		return map.getTileInDirection(tile, dir1)
	return map.getTileInDirection(tile, Vector2(dir1,dir2))
func MoveAndAttack(unit,target):
	unit = unit.head
	var nextTile = unit.tile
	var curTile = unit.tile
	if target is Vector2:
		for _i in range(unit.speed):
			nextTile = map.getTileInDirection(nextTile,target)
			if nextTile.occupants.size() ==0:
				Action("move", [unit, nextTile])
			else:
				if unit.hasVariable("Multistrike"):
					for _eoorork in range(getVar(unit, "Multistrike")):
						Action("Attack",[unit, nextTile.occupants[0]])
				else:
					Action("Attack",[unit, nextTile.occupants[0]])
				break
	else:
		var targets = map.selectAll(nextTile,unit.sight,target,["any"])
		for _i in range(unit.speed):
			var enemy = map.selectRandom(nextTile,unit.attackrange,target,["any"])
			if enemy!=null:
				if unit.hasVariable("Multistrike"):
					for _eoorork in range(getVar(unit, "Multistrike")):
						Action("Attack",[unit, enemy])
				else:
					Action("Attack",[unit, enemy])
				break
			else:
				curTile = nextTile
				nextTile = map.pathFindToSet(curTile,targets)
				if nextTile.occupants.size() ==0:
					Action("move", [unit, nextTile])
				elif nextTile.occupants[0].head == unit.head:
					Action("move", [unit, nextTile])
					Action("move", [nextTile.occupants[0], curTile])
				else:
					for neigh in curTile.neighs:
						if neigh.dist !=null and neigh.dist < curTile.dist and neigh.occupants.size() == 0:
							nextTile = neigh
							Action("move", [unit, nextTile])
							break
					
					
				
func setStatus(tile, statname, val):
	if tile == null:
		return false
	var units
	if not tile is Array:
		units = [tile]
	else:
		units= tile
	for tile in units:
		if tile.occupants.size() > 0:
			tile.occupants[0].setStatus(statname, val)
func addStatus(tile, statname, val):
	if tile == null:
		return false
	var units
	if not tile is Array:
		units = [tile]
	else:
		units= tile
	for tile in units:
		if tile.occupants.size() > 0:
			tile.occupants[0].addStatus(statname, val)
func clearAllStatuses(tiles = "Player"):
	if tiles is String and tiles  == "Player":
		tiles = [enemyController.Player.tile]
	if not tiles is Array:
		tiles = [tiles]
	for tile in tiles:
		for unit in tile.occupants:
			for stat in unit.status:
				unit.setStatus(stat, 0)
	
func Lose(enemy):
	yield(get_tree().create_timer(.5),"timeout")
	if enemy !=null:
		var image = enemy.get_node("Image").texture
		get_node("/root/global").lossImage = image
	get_tree().change_scene("res://Images/UIArt/LoseScreen.tscn")
func Win():
	yield(get_tree().create_timer(1),"timeout")
	get_tree().change_scene("res://Images/UIArt/WinScreen.tscn")

func pickConsumed():
	yield(get_tree().create_timer(.2),"timeout")
	var possible = []
	for other in theVoid.tile.neighs:
		if other.occupants.size()==0:
			possible.append(other)
	if possible.size() == 0:
		possible = theVoid.tile.neighs
	var consumed = Utility.choice(possible)
	if theVoid.links.size()==0:
		var linkage = $UnitLibrary.getLinkageByName("VoidTentacles")
		linkage.setup(theVoid,consumed,theVoid)
		add_child(linkage)
		theVoid.links.append(linkage)
	else:
		theVoid.links[0].setup(theVoid,consumed,theVoid)
	cardController.consumed = consumed

func save()->Dictionary:
	var saveunits=[]
	for unit in units:
		saveunits.append(unit.save())
	return {
		"units":saveunits,
		"windDirection": [windDirection.x,windDirection.y],
		"maxdifficulty": maxdifficulty,
		"player": Player.save(),
		"voidNext":map.nodes.find(voidNext),
		"theVoid":units.find(theVoid)
	}
func loadFromSave(save:Dictionary, parent):
	var step = self.Load(parent)
	if step is GDScriptFunctionState:
		yield(step, "completed")
	units = []
	for saveunit in save.units:
		var unit  = $UnitLibrary.getUnitByName(saveunit.title)
		add_child(unit)
		unit.loadFromSave(saveunit)
		units.append(unit)
		unit.scale = unitscale
		unit.onSummon(unit,true)
	self.windDirection = Vector2(save.windDirection[0], save.windDirection[1])
	self.maxdifficulty = save.maxdifficulty
	Player = $UnitLibrary.getUnitByName("Mora")
	Player.loadFromSave(save.player)
	Player.scale = unitscale
	add_child(Player)
	Player.onSummon(Player,true)
	
	voidNext = map.nodes[int(save.voidNext)]
	theVoid = units[int(save.theVoid)]

func testAllUnits():
	for unitname in $UnitLibrary.units:
		if unitname!= "Mora":
			Summon( map.getRandomEmptyNode(["any"]), unitname)
