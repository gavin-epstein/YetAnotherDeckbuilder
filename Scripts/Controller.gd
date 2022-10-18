extends Node2D
var Play
var Hand
var enemyController
var cardController
var animationController
var map
var selectedCard = null
var test = false
var lastTargets= null
var pausetime = 1
onready var Message = get_node("/root/Scene/Message")
signal resumeExecution
const testMethods = ["Attack","addArmor","addBlock",
					"gainStrength","gainMaxHealth",
					"heal","Summon","setVar","addVar",
					"setStatus","clearAllStatus",
					"move","reshuffle","shuffle","draw",
					"play","setEnergy","gainEnergy","discard",
					"discardAll","cardreward","purge","create",
					"createByMod","voided","endofturn","startofturn",
					"movePlayer","damage","moveUnits","summon",
					"armor","block","consume","addStatus","say",
					"kill"
					]
const directedmethods= ["setStatus","addStatus"]
var hits = []
func _ready() -> void:
	Play = get_node("/root/Scene/CardController/Play")
	Hand = get_node("/root/Scene/CardController/Hand")
	enemyController = get_node("/root/Scene").enemyController
	cardController = get_node("/root/Scene").cardController
	map = get_node("/root/Scene").map
	pausetime = global.animationspeed
	global.connect("animspeedchanged",self,"on_animation_speed_change")
func on_animation_speed_change(val):
	pausetime = val
func Action(method:String, argv:Array,silent = false) -> bool:
	var interrupted = false
	#stoppable is really "unstoppable"
	var stoppable = silent
	if silent is Array:
		stoppable = silent[1]
		silent = silent[0]
	var res
	if !test:
		pass
		#print(method +" "+ Utility.join(" ", argv))
	if not stoppable:
		for card in Play.cards:
			var interres = card.Interrupts(method, argv)
			if interres is GDScriptFunctionState:
				interres = yield(interres,"completed")
			if interres:
				interrupted = true
				print(method+str(argv) + " interrupted by " + card.title)
		for card in Hand.cards:
			var interres = card.Interrupts("hand"+str(method), argv)
			if interres is GDScriptFunctionState:
				interres = yield(interres,"completed")
			if interres:
				interrupted = true
				print(method+str(argv) + " interrupted by " + card.title)
		
	if not interrupted:
		
		if self.has_method(method):
			if test and method in testMethods:
				if method in directedmethods and argv[0]!=null:
					var tiles = argv[0]
					if not tiles is Array:
						tiles = [tiles]
					var enemy=false;
					var friendly= false;
					for tile in tiles:
						if tile is Node2D and tile.has_method("hasOccupant") and tile.occupants.size()>0:
							if tile.occupants[0]!=null and tile.occupants[0].hasProperty("friendly"):
								friendly =true
							else:
								enemy=true
					if friendly:
						hits.append(	method+":friendly")
					else:
						hits.append(method+":-friendly")
				else:
					hits.append(method)
			else:
			#	print(method)
			#	print(argv)
				res =  self.callv(method, argv)
				if res is GDScriptFunctionState:
					res = yield(res,"completed")
			
		else:
			print("attempting to " + method)
		if not silent and res:
			#look through play, if card is removed from play don't increment index
			var ind = 0
			while Play.cards.size() > ind:
				var card = Play.cards[ind]
				var res2 = card.Triggered(method, argv)
				if res2 is GDScriptFunctionState:
					res2 = yield(res2,"completed")
				
				if card in Play.cards:
					ind+=1
			ind = 0
			while Hand.cards.size() > ind:
				var card = Hand.cards[ind]
				var res2 = card.Triggered("hand:"+str(method), argv)
				if res2 is GDScriptFunctionState:
					res2 = yield(res2,"completed")
				
				if card in Hand.cards:
					ind+=1
			ind = 0
			while enemyController.units.size() > ind:
				var unit = enemyController.units[ind]
				if unit == null:
					enemyController.units.erase(unit)
					continue
				var res2 = unit.Triggered(method,argv)
				if res is GDScriptFunctionState:
					res2 = yield(res2,"completed")
				if unit in enemyController.units:
					ind+=1
	if self.has_method("updateDisplay") and not test:
		self.call("updateDisplay")
	if not test and not cardController.isPlayerTurn:
		yield(get_tree().create_timer(.01*pausetime),"timeout")
	return res

func startTest():
	enemyController.test = true
	cardController.test = true
	enemyController.hits = []
	cardController.hits = []
func endTest():
	enemyController.test = false
	cardController.test = false
	return enemyController.hits + cardController.hits
	
func setVar(card, varname, amount):
#	print("set " + varname + " to " + str(amount) + " on " + card.title)
	if card is Array:
		if card.size()==0:
			return false
		card = card[0]
	if card == null :
		return false
	if  card.has_method("hasOccupant"):
		if card.occupants.size()==0:
			return false
		card = card.occupants[0]
	card.vars["$" + varname] = amount
	return true
func addVar(card, varname, amount):
	if card is Array:
		if card.size()==0:
			return false
		card = card[0]
	if card == null :
		return false
	if  card.has_method("hasOccupant"):
		if card.occupants.size()==0:
			return false
		card = card.occupants[0]
	if card.vars.has("$"  +varname):
		card.vars["$" + varname] = card.vars["$" + varname]  + amount
		return true
	return false
func getVar(card, varname):
	if card == null:
		return false
	if varname=="title":
		return card.title
	return card.vars["$"+varname];
func selectCards(locs, predicate,message,num = 1,random=false):
	#print("Select input allowed " +str( cardController.inputAllowed))
	#print("Select " + loc + "  "  + str(predicate))
	if locs is String and locs == "all":
		locs = ["Deck","Hand", "Play", "Discard", "Burn"]
	elif locs is String:
		locs = [locs]
	var selectcount = 0
	var newlocs = []
	for loc in locs:
		if loc == "Burn":
			loc = "Voided"
		print("looking at " + loc)
		loc = cardController.get_node(loc)
		newlocs.append(loc)
		for card in loc.cards:
			if card.processArgs(predicate, []):
				card.highlight()
				selectcount+=1
	locs = newlocs
	#print("selectcount: " + str(selectcount))	
	if random and num is int: #random
		var possible = []
		for loc in locs:
			for card in loc.cards:
				if card.highlighted:
					possible.append(card)
		
		var cards  = Utility.choosex(possible,num)
		if cards.size()==1:
			cardClicked(cards[0])
			return cards[0]
		if cards.size()>0:
			cardClicked(cards[0])
		return cards
	if num is String and num == "all": #all
		var possible = []
		for loc in locs:
			for card in loc.cards:
				if card.highlighted:
					possible.append(card)
			if possible.size()>0:
				cardClicked(possible[0])
			#print(possible)
			return possible
	#otherwise select 1.
	#if only 1 is available return it
	if selectcount == 1:
		for loc in locs:
			for card in loc.cards:
				if card.highlighted:
					cardClicked(card)
					return card
		print("Selectable Card has Moved?")
	#if none available, null
	elif selectcount == 0:
		return null
	#if all are the same return the first one
	else:
		var prototype = null
		var alltheSame = true
		for loc in locs:
			for card in loc.cards:
				if card.highlighted:
					if prototype == null:
						prototype = card
					else:
						if not prototype.isIdentical(card):
							alltheSame = false
							break
			if not alltheSame:
				break
		if alltheSame:
			cardClicked(prototype)
			return prototype
	#finally, let the player click
	#inputAllowed = false
	#forceFocus(null)
	
	selectedCard = null
	Message.get_node("Message").bbcode_text = "[center]"+message+"[/center]"
	Message.visible = true
	if locs.size() == 1:
		if locs[0] is CardPile:
			locs[0].display(50,50 )
	else:
		cardController.get_node("CardPileDisplay").multidisplay(locs)
	cardController.updateDisplay()
	#print("Select input allowed " +str( cardController.inputAllowed))
	yield(self, "resumeExecution")
	#releaseFocus(selectedCard)
	Message.visible = false
	for loc in locs:
		if loc is CardPile:
			loc.undisplay()
	#print("Select input allowed post undisplay " +str( cardController.inputAllowed))
	return selectedCard

func cardClicked(card):
	selectedCard = card
	#inputAllowed  = true
	cardController.releaseFocus(card)
	for card in Hand.cards:
		card.dehighlight()
	for card in cardController.Play.cards:
		card.dehighlight()
	for card in cardController.Deck.cards:
		card.dehighlight()
	for card in cardController.Voided.cards:
		card.dehighlight()
	for card in cardController.Discard.cards:
		card.dehighlight()
	emit_signal("resumeExecution")
	
func selectTiles(targets, distance, tile, message = "Pick a target"):
	#Let them choose on the map, but not play another card
	if targets[0] is String and targets[0] == "lastTargets":
		return lastTargets
	cardController.forceFocus(map)
	if (tile is String and tile == "Player") or tile == null:
		tile = enemyController.Player.tile
	var enemies = []
	if targets[0] is int or targets[0] is float:
		for _i in range(int(targets[0])):
			enemies.append(map.selectRandom(tile,distance,targets[2],targets[1]))
	elif targets[0] == "all":	
		enemies = map.selectAll(tile,distance,targets[2],targets[1],true,true)
	elif targets[0]=="any":
		var enemy = map.select(tile,distance,targets[2],targets[1],message)
		if enemy is GDScriptFunctionState:
			enemy = yield(enemy,"completed")
		if enemy ==null:
			cardController.releaseFocus(map)
			return []
		enemies.append(enemy)
	elif targets[0]=="splash" and targets.size() >=4:
		var centers = callv("selectTiles",targets[3])
		if centers is GDScriptFunctionState:
			centers = yield(centers, "completed")
		for c in centers:
			enemies += map.selectAll(c,distance,targets[2],targets[1])
	elif targets[0]=="direct":
		enemies = targets[1]
	lastTargets = enemies
	cardController.releaseFocus(map)
	return enemies
	
func hasProperty(tile, prop, mode="or"):
	if tile ==null or tile is Array and tile.size()==0:
		return false
	if not tile is Array:
		tile = [tile]
	for thing in tile:
		if thing is GridNode:
			if thing.hasOccupant(prop):
				if mode=="or":
					return true
			else:
				if mode == "and":
					return false
	return mode == "and"
func getStatus(tile, statname) -> int:
	#print(tile, statname)
	if tile == null:
		return 0
	var units
	if not tile is Array:
		units = [tile]
	else:
		units= tile
	var sum = 0
	for tile in units:
		if tile.has_method("hasOccupant") and  tile.occupants.size() > 0:
			tile = tile.occupants[0]
		if tile.has_method("getStatus"):
			var val = tile.getStatus(statname)
			sum += val
	#print("sum: ", sum)
	return sum
func countTypes(loc, type) ->  int:
	if loc == "Energy":
		return cardController.Energy
	elif loc == "Battery":
		return cardController.get_node("Battery").charge
	elif loc == "MaxBattery":
		return cardController.get_node("Battery").capacity
	loc = cardController.get_node(loc)
	var count = 0
	for card in loc.cards:
		if card.hasType(type):
			count+=1	
	return count
