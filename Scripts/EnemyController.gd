extends "res://Scripts/Controller.gd"
var turncount = 1;
var totaldifficulty = 0;
var maxdifficulty = 6;
var units=[]
var Player
var theVoid
var windDirection = Vector2(0,1).rotated(rand_range(0,2*PI))
var voidNext
const bossnames = ["Queen Orla", "LORD OF THE SWAMP","The Last Automaton"]
const bossicons = ["res://Images/UIArt/bossIcons/Queen Orla.png", "res://Images/UIArt/bossIcons/SwampLord.png","res://Images/UIArt/bossIcons/Cog.png"]
var boss1
var boss

const unitscale=Vector2(.17,.17)
# Called when the node enters the scene tree for the first time.
func Load(parent):
	#yield(parent,"ready")
	
	map = parent.map
	cardController = parent.cardController
	animationController = parent.animationController
	enemyController=self
	var step = $UnitLibrary.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	boss = randi()%bossnames.size()
	boss1 = bossnames[boss]
	get_node("/root/Scene/voidhealthbar/bossIcon1/image").texture = load(bossicons[boss])
	

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
func addPlayerAndVoid(playerTile=null):
	yield(map, "mapGenerated");
	var unit  = $UnitLibrary.getUnitByName("Void")
	var node = map.voidNode
	theVoid = unit
	addUnit(unit,node)
	unit = $UnitLibrary.getUnitByName("Mora")
	Player = unit
	if playerTile==null:
		playerTile=map.getRandomEmptyNode(["any"])
	addUnit(unit, playerTile)
	units.erase(Player)
	Player.setStatus("stunned",0)
	get_node("/root/Scene/morahealthbar").unit = Player
	get_node("/root/Scene/voidhealthbar").unit = theVoid
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
	if unit.hasProperty("friendly"):
		#friendly units go first
		units.push_front(unit)
	else:
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
	if unit.has_method("hasOccupant"):
		if unit.occupants.size()==0:
			return false
		unit = unit.occupants[0]
	unit.facing((node.position - unit.position).angle())
	if not node.sentinel and not (unit.status.has("immovable") or unit.status.has("entangled")):
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
		var res = unit.startOfTurn()
		if res is GDScriptFunctionState:
			yield(res, "completed")
	for unit in units:
		if unit != null and not unit.skipturn and not unit.status.has("stunned"):
			var res = unit.Triggered("turn",[])
			if res is GDScriptFunctionState:
				yield(res, "completed")
			yield(get_tree().create_timer(.15 * pausetime), "timeout")
	for unit in units:
		if unit != null:
			var res = unit.endOfTurn()	
			if res is GDScriptFunctionState:
				yield(res, "completed")
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
func Attack(attacker, target,types = [],damage = -1):
	if attacker!=null:
		attacker = attacker.head
	if target  == null:
		return false
	
	if target is Array:
		for thing in target:
			Attack(attacker,thing, types, damage)
		return true
	if not target.has_method("isUnit"):
		if target.occupants.size() ==0:
			return false
		target= target.occupants[0]
	target = target.get("head")
	if target.status.has("stealth"):
		return false
	if attacker!=null:
		attacker.facing((target.position - attacker.position).angle())
		target.facing((attacker.position - target.position).angle())
	if damage < 0 and attacker!=null: 
		damage = attacker.getStrength()
	
	if types.size() ==0 and attacker!=null:
		 types = attacker.damagetypes
	if attacker!=null:
		attacker.playAnimation("attack")
	target.playAnimation("defend")
	var res = target.takeDamage(damage, types, attacker)
	if res is GDScriptFunctionState:
		res = yield(res, "completed")
	if res.size() > 1 and res[1] =="kill":
		if attacker!=null:
			attacker.Triggered("slay",[target])
	return true
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
func setStrength(unit,amount):
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
		unit.strength=amount
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
		unit.Triggered("blockchanged",[amount])
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
		if unit.health <=0:
			unit.die(null)
func countNames(loc, name) -> int:
	var count = 0
	for unit in units:
		if unit == null:
			units.erase(unit)
			continue
		if unit.hasName(name):
			count+=1
	return count


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
				var res = Action("move", [unit, nextTile])
				if res is GDScriptFunctionState:
					yield(res, "completed")
			else:
				if unit.hasVariable("Multistrike"):
					for _eoorork in range(getVar(unit, "Multistrike")):
						var res = Action("Attack",[unit, nextTile.occupants[0]])
						if res is GDScriptFunctionState:
							yield(res, "completed")
				else:
					var res = Action("Attack",[unit, nextTile.occupants[0]])
					if res is GDScriptFunctionState:
						yield(res, "completed")
				break
	else:
		var targets = map.selectAll(nextTile,unit.sight,target,["any"])
		for _i in range(unit.speed):
			var enemy = map.selectRandom(nextTile,unit.attackrange,target,["any"])
			if enemy!=null:
				if unit.hasVariable("Multistrike"):
					for _eoorork in range(getVar(unit, "Multistrike")):
						var  res = Action("Attack",[unit, enemy])
						if res is GDScriptFunctionState:
							yield(res, "completed")
				else:
					var res = Action("Attack",[unit, enemy])
					if res is GDScriptFunctionState:
						yield(res, "completed")
				break
			else:
				curTile = nextTile
				nextTile = map.pathFindToSet(curTile,targets)
				if nextTile.occupants.size() ==0:
					var res = Action("move", [unit, nextTile])
				elif nextTile.occupants[0].head == unit.head:
					var res = Action("move", [unit, nextTile])
					if res is GDScriptFunctionState:
						yield(res, "completed")
					res = Action("move", [nextTile.occupants[0], curTile])
					if res is GDScriptFunctionState:
						yield(res, "completed")
				else:
					for neigh in curTile.neighs:
						if neigh.dist !=null and curTile.dist!=0  and curTile.dist !=null and neigh.dist < curTile.dist and neigh.occupants.size() == 0:
							nextTile = neigh
							var res = Action("move", [unit, nextTile])
							if res is GDScriptFunctionState:
								yield(res, "completed")
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
		var image = enemy.get_node("Resizer/Image").texture
		get_node("/root/global").lossImage = image
	get_tree().change_scene("res://Images/UIArt/LoseScreen.tscn")
func Win():
	yield(get_tree().create_timer(.5),"timeout")
	get_tree().change_scene("res://Images/UIArt/WinScreen.tscn")

func pickConsumed():
	yield(get_tree().create_timer(.2*pausetime),"timeout")
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
func spawnMiniBoss():
	if getVar(theVoid,"BossesSummoned")==0:
		Summon(selectTiles( [1 ,["any"], "empty"],1, theVoid.tile ), boss1)
		return true
func save()->Dictionary:
	var saveunits=[]
	for unit in units:
		if unit!=null:
			saveunits.append(unit.save())
	return {
		"units":saveunits,
		"windDirection": [windDirection.x,windDirection.y],
		"maxdifficulty": maxdifficulty,
		"player": Player.save(),
		"voidNext":map.nodes.find(voidNext),
		"theVoid":units.find(theVoid),
		"boss":boss,
		"boss1":boss1
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
	boss1 = save.boss1
	boss = int(save.boss)
	
	voidNext = map.nodes[int(save.voidNext)]
	theVoid = units[int(save.theVoid)]
	get_node("/root/Scene/morahealthbar").unit = Player
	get_node("/root/Scene/voidhealthbar").unit = theVoid
	get_node("/root/Scene/voidhealthbar/bossIcon1/image").texture = load(bossicons[boss])
#For backwards complatibility
func select(targets, distance, tile):
	return selectTiles(targets, distance, tile)
func say(unit, message, time=0):
	message = str(message)
	if unit == null:
		return false
	var units
	if not unit is Array:
		units = [unit]
	else:
		units= unit
	for tile in units:
		if tile ==null:
			continue
		if tile.has_method("hasOccupant"):
			if tile.occupants.size()==0:
				continue
			tile = tile.occupants[0]
		if time == 0:
			tile.say(message)
		else:
			tile.say(message,time)
func kill(unit,attacker=null):
	if unit == null:
		return false
	var units
	if not unit is Array:
		units = [unit]
	else:
		units= unit
	for unit in units:
		if unit ==null:
			continue
		if unit.has_method("hasOccupant"):
			if unit.occupants.size()==0:
				return false
			unit = unit.occupants[0]
		unit.die(attacker)
func testAllUnits():
	Summon( map.getRandomEmptyNode(["any"]), "Suspicious Mound")
	Summon( map.getRandomEmptyNode(["any"]), "Death Worm")
#	for unitname in $UnitLibrary.units:
#		if unitname!= "Mora":
#			Summon( map.getRandomEmptyNode(["any"]), unitname)
