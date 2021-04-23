extends "res://Scripts/Controller.gd"
const testmode = false
signal resumeExecution
var cardtemplate = preload("res://Card.tscn");
var triggers = {}
var Deck
var Discard
var Hand
var Library
var Choice
var Energy
var inputdelay = 0
var inputAllowed = true
var focus
var selectedCard
var map
var lastPlayed
var lastTargets
var consumed
var focusStack=[]
var lastfocus
class_name CardController
#func _process(delta: float) -> void:
#	if inputAllowed:
#		$Reaction.modulate = Color(0,0,0)
#	else:
#		$Reaction.modulate = Color(1,1,1)
func Load(parent)-> void: 
	cardController = self
	Deck = get_node("Deck")
	Hand = get_node("Hand")
	Discard = get_node("Discard")
	Play = get_node("Play")
	Library = get_node("CardLibrary")
	Choice = get_node("Choice")
	var step = Library.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("Cards loaded")
	Play.add_card(Library.getCardByName("Adventurer"))
	Play.add_card(Library.getRandomByModifier(["void"]))
	Energy = 3
	map = parent.map
	enemyController = parent.enemyController
	self.updateDisplay()
	if not testmode:
		for _i in range(2):
			Deck.add_card(Library.getCardByName("Common Loot"))
			Deck.add_card(Library.getCardByName("Smack"))
			$Reaction.add_card(Library.getCardByName("Scratch"))
		for _i in range(3):
			Deck.add_card(Library.getCardByName("Defend"))
		Deck.add_card(Library.getCardByName("Crossbow"))
		Deck.add_card(Library.getCardByName("Dash"))
		Deck.add_card(Library.getCardByName("Lunge"))
		$Reaction.add_card(Library.getCardByName("Endure"))
#		#Test Cards
#		Deck.add_card(Library.getCardByName("Secrecy"))
#		Deck.add_card(Library.getCardByName("Sifting Breath"))
#		Deck.add_card(Library.getCardByName("Windmill"))
		shuffle()
		step = Action("draw",[5])
		if step is GDScriptFunctionState:
			yield(step,"completed")
	else:
		for card in Library.cards:
			Deck.add_card(Library.getCardByName(card.title))
		enemyController.testAllUnits()


	

func draw(x)->bool:
	var results = {}
	for i in range(x):

		if Hand.is_full():
			return i!=0

		if Deck.size() == 0:
			if Discard.size() ==0:
				return i!=0
			else:
				Action("reshuffle",[])
		var card = Deck.getCard(0)
		move("Deck","Hand",card)
		if card in Hand.cards:
			card.Triggered("onDraw",[x])
			self.triggerAll("cardDrawn",[card])
	return true

func reshuffle()->bool:
	if Discard.size()==0:
		return false
	Deck.cards +=Discard.cards
	Deck.cards.shuffle()
	Discard.cards = []
	return true
func shuffle()->bool:
	if Deck.size() ==0:
		return false
	Deck.cards.shuffle()
	return true

func play(card)->bool:
	
	print("Playing " + card.title)
	if card.modifiers.has("unplayable"):
		return false
	var cost = getVar(card, "Cost")
	if cost is int and cost > Energy:
		return false
	elif cost is String and cost == "X":
		setVar(card,"X",Energy)
		Energy = 0
	if cost is int:
		Energy -= cost
	
	lastPlayed = card
	#forceFocus(self)
	card.mouseon= false
	inputAllowed = false
	self.move("Hand","Play", card)
	updateDisplay()
	var results = card.Triggered("onPlay",[card])
	if results is GDScriptFunctionState:
		results = yield(results,"completed")
	setVar(card,"Cost",getVar(card,"BaseCost"))
	updateDisplay()
	#releaseFocus(self)
	inputAllowed = true
	return true
	

#location must be capitalized	 
func countTypes(loc, type) -> int:
	if loc == "Energy":
		return Energy
	loc = get_node(loc)
	var count = 0
	for card in loc.cards:
		if card.hasType(type):
			count+=1	
	return count
func countNames(loc, name) -> int:
	loc = get_node(loc)
	var count = 0
	for card in loc.cards:
		if card.hasName(name):
			count+=1
	return count
func countModifiers(loc, mod) -> int:
	loc = get_node(loc)
	var count = 0
	for card in loc.cards:
		if card.hasModifier(mod):
			count+=1
	return count
func move(loc1, loc2, card):
	if card is bool:
		return card
	loc1 = get_node(loc1)
	loc2 = get_node(loc2)
	if loc1.remove_card(card):
		loc2.add_card(card)
		return true
	return false
func setEnergy(num):
	Energy = num
	$Energy.updateDisplay()
	return true
func discardAll(silent = false):
	var ind =0;
	while Hand.cards.size() >ind:
		var card = Hand.cards[ind]
		if not card.modifiers.has("retain"):
			Action("discard", [card, silent], silent);
		else:
			card.Triggered("onRetain",[card])
			if card in Hand.cards:
				ind+=1
	return true
	
func discard(card, silent = false, loc = "Hand"):
	if card == null:
		return false
	var res =  move(loc, "Discard", card)
	if not silent and res:
		card.Triggered("onDiscard", [card])
	return res
	
func updateDisplay():
	Hand.updateDisplay()
	Discard.updateDisplay()
	Play.updateDisplay()
	Deck.updateDisplay()
	$Voided.updateDisplay()
	$Energy.updateDisplay()
	$Reaction.updateDisplay()
	if enemyController!=null and enemyController.Player != null:
		enemyController.Player.updateDisplay()
		for unit in enemyController.units:
			if unit !=null:
				unit.updateDisplay()
func cardreward(rarity, count):
	Choice.generateReward(rarity, count)
	yield(Choice,"cardchosen")
	return true

func purge(card):
	if card == null:
		return false
	if Hand.remove_card(card) or Deck.remove_card(card) or Play.remove_card(card) or Discard.remove_card(card) or $Reaction.remove_card(card) or $Voided.remove_card(card):
		releaseFocus(card)
		card.queue_free()
		return true
	return false

func takeFocus(item) -> bool:
	#printFocus()
	if $Choice.visible and not item in $Choice.cards:
		return false
	
	if focus == null:
		focus = item
		printFocus()
		return true
		
	elif focus == item:
		return true
	return false

func releaseFocus(item) -> bool:
	#printFocus()
	if focus == item:
		#print("Focus Released")
		if focusStack.size()>0:
			focus= focusStack.pop_back()
		else:
			focus = null
		printFocus()
		return true
	return false
func forceFocus(item):
	printFocus()
	if focus == item:
		return false
	focusStack.push_back(focus)
	focus = item
	printFocus()
	return true
func printFocus():
	return
	if focus ==lastfocus:
		return
	if focus != null:
		print("Focus is on ", focus.get("name"),": ", focus.get("title")," ", focus.get_parent().get("name"))
	else:
		print("Focus is null")	
	if focusStack.size() >0:
		print("FocusStack: ", str(focusStack))
	lastfocus = focus
func create(card, loc,spawner=null,silent=false):
	loc = get_node(loc)
	var added: Node2D
	if card is String:
		added = Library.getCardByName(card)
	else:
		added = cardtemplate.instance();
		card.deepcopy(added)
	
	if spawner !=null and spawner.has_method("get_global_transform"):
		add_child(added)
		added.moveTo(spawner.get_global_transform().get_origin(),Vector2(.2,.2))
		added.updateDisplay()
		added.set_process(false)
		yield(get_tree().create_timer(.1),"timeout")
		added.set_process(true)
	loc.add_card(added)
	added.updateDisplay()
	if not silent:
		triggerAll("onCreate",[added,loc])
	return added
func createByMod(modifiers, loc,spawner=null,silent=false):
	loc = get_node(loc)
	var added = Library.getRandomByModifier(modifiers)
	if spawner !=null and spawner.has_method("get_global_transform"):
		added.moveTo(spawner.get_global_transform().get_origin(),Vector2(.2,.2))
	loc.add_card(added)
	if not silent:
		triggerAll("onCreate",[added,loc])
	return added
	
func gainEnergy(num):
	Energy += num
	$Energy.updateDisplay()
	return true
	
func voided(card, loc):
	
	if move(loc, "Voided", card):
		card.Triggered("onVoided",[self])
		return true
	return false

func endofturn():
	if enemyController.Player==null:
		enemyController.Lose(null)
		return false
	enemyController.maxdifficulty+=.9
	enemyController.Player.endOfTurn()
	return true

func startofturn():
	if enemyController.Player==null:
		enemyController.Lose(null)
		return false
	enemyController.Player.startOfTurn()
	return true


func _on_EndTurnButton_input_event(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and takeFocus(self) and inputAllowed:
		inputAllowed = false
		releaseFocus(self)
		inputdelay = 0
		var res = Action("endofturn",[],false)
		if res is GDScriptFunctionState:
			yield(res,"completed")
		#Enemies go here
		takeFocus(self)
		
		res = enemyController.enemyTurn()
		if res is GDScriptFunctionState:
			yield(res,"completed")
		
		releaseFocus(self)
		res = Action("startofturn", [], false)
		if res is GDScriptFunctionState:
			yield(res,"completed")
		inputAllowed = true
func select(loc, predicate,message,num = 1,random=false):
	
	loc = get_node(loc)
	var selectcount = 0
	for card in loc.cards:
		if card.processArgs(predicate, []):
			card.highlight()
			selectcount+=1
	print("selectcount: " + str(selectcount))	
	if random: #random
		var possible = []
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
		for card in loc.cards:
			if card.highlighted:
				possible.append(card)
		if possible.size()>0:
			cardClicked(possible[0])
		return possible
	#otherwise select 1.
	#if only 1 is available return it
	if selectcount == 1:
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
		for card in loc.cards:
			if card.highlighted:
				if prototype == null:
					prototype = card
				else:
					if not prototype.isIdentical(card):
						alltheSame = false
						break
		if alltheSame:
			cardClicked(prototype)
			return prototype
	#finally, let the player click
	#inputAllowed = false
	#forceFocus(null)
	if loc is CardPile:
		loc.display()
		$Message.rect_position= Vector2(376,560)
	else:
		$Message.rect_position= Vector2(376,280)
	selectedCard = null
	$Message/Message.bbcode_text = "[center]"+message+"[/center]"
	$Message.visible = true
	updateDisplay()
	yield(self, "resumeExecution")
	#releaseFocus(selectedCard)
	$Message.visible = false
	if loc is CardPile:
		$CardPileDisplay.undisplay()
	return selectedCard
func cardClicked(card):
	selectedCard = card
	#inputAllowed  = true
	releaseFocus(card)
	for card in Hand.cards:
		card.dehighlight()
	for card in Play.cards:
		card.dehighlight()
	for card in Deck.cards:
		card.dehighlight()
	for card in $Reaction.cards:
		card.dehighlight()
	for card in $Voided.cards:
		card.dehighlight()
	for card in $Discard.cards:
		card.dehighlight()
	emit_signal("resumeExecution")
	
func movePlayer(dist,terrains = ["any"]):
	forceFocus(map)
	var tile = map.select(enemyController.Player.tile, dist,"empty", terrains,"Pick a tile to move to");
	if tile is GDScriptFunctionState:
		tile = yield(tile, "completed")
	if tile == null:
		releaseFocus(map)
		return false
	enemyController.move(enemyController.Player, tile)
	releaseFocus(map)
	return true
	
func selectTiles(targets, distance, tile):
	#Let them choose on the map, but not play another card
	
	if targets[0] is String and targets[0] == "lastTargets":
		return lastTargets
	forceFocus(map)
	if (tile is String and tile == "Player") or tile == null:
		tile = enemyController.Player.tile
	var enemies = []
	if targets[0] is int or targets[0] is float:
		for _i in range(int(targets[0])):
			enemies.append(map.selectRandom(tile,distance,targets[2],targets[1]))
	elif targets[0] == "all":	
		enemies = map.selectAll(tile,distance,targets[2],targets[1])
	elif targets[0]=="any":
		var enemy = map.select(tile,distance,targets[2],targets[1],"Pick a target")
		if enemy is GDScriptFunctionState:
			enemy = yield(enemy,"completed")
		if enemy ==null:
			releaseFocus(map)
			return []
		enemies.append(enemy)
	elif targets[0]=="splash" and targets.size() >=4:
		var centers = callv("selectTiles",targets[3])
		if centers is GDScriptFunctionState:
			centers = yield(centers, "completed")
		for c in centers:
			enemies += map.selectAll(c,distance,targets[2],targets[1])
	lastTargets = enemies
	releaseFocus(map)
	return enemies
	
func damage(amount, types, targets,distance, tile =null):
	amount=enemyController.Player.getStrength(amount)
	if tile == null:
		tile = "Player"
	var property
	var terrains
	if targets.size() < 2:
		targets.append( ["any"])
	if targets.size() < 3:
		if targets[0] is int:
			targets.append("-friendly")
		else:
			targets.append("-Player")

	var enemies = selectTiles(targets,distance,tile)
	if enemies is GDScriptFunctionState:
		enemies = yield(enemies,"completed")
	
	if enemies == null or enemies.size()== 0:
		return false
	for node in enemies:
		if node == null or node.occupants.size() == 0:
			#Enemy has been removed by another effect
			continue
		var unit =  node.occupants[0]
		var dmg = unit.takeDamage(amount,types,enemyController.Player)
		if lastPlayed !=null:
			if dmg.size() > 1 and dmg[1] == "kill":
				lastPlayed.Triggered("slay",[unit])
			if dmg.size()>0:
				lastPlayed.Triggered("attack",dmg)
	return true
func moveUnits(targets,distance,tile="Player",direction="any",movedist="1"):
	var property
	var terrains
	if targets.size() < 2:
		targets.append( ["any"])
	if targets.size() < 3:
		targets.append("-Player")

	var enemies = selectTiles(targets,distance,tile)
	if enemies is GDScriptFunctionState:
		enemies = yield(enemies,"completed")
	if not enemies is Array:
		enemies = [enemies]
	for enemy in enemies:
		if direction is String and direction == "any":
			var dest = selectTiles(["any",["any"],"empty"], movedist, enemy )
			if dest is GDScriptFunctionState:
				dest = yield(dest,"completed")
			if enemy.occupants.size()>0 and dest.size()>0:
				enemyController.move(enemy.occupants[0],dest[0])
		else:
			var dir
			if direction is String and direction == "away":
				dir = enemy.position - enemyController.Player.tile.position
			elif direction is String and direction == "towards":
				dir = enemyController.Player.tile.position-enemy.position 
			else:
				dir = Vector2(direction[0],direction[1])
			var dest = enemy
			for _i in range(movedist):
				var nextDest = map.getTileInDirection(dest,dir)
				if !nextDest.sentinel and nextDest.occupants.size() ==0:
					dest = nextDest
				else:
					break
			if enemy.occupants.size()>0:
				enemyController.move(enemy.occupants[0],dest)
func heal(amount):
	enemyController.heal(enemyController.Player,amount)
	return true

func summon(unitName, targets, distance,tile="Player") :
	var terrains
	var locs = []
	if tile is String and tile == "Player":
		tile = enemyController.Player.tile
	if targets.size() < 2:
		terrains = ["any"]
	else:
		terrains = targets[1]

	targets = [targets[0],terrains,"empty"]
	locs = selectTiles(targets,distance,tile)
	if locs is GDScriptFunctionState:
		locs = yield(locs,"completed")
	if locs == null or locs.size() == 0:
		return false
	var unit = enemyController.get_node("UnitLibrary").getUnitByName(unitName)
	for node in locs:
		enemyController.addUnit(unit,node)
	return true
func armor(amount):
	enemyController.addArmor(enemyController.Player,amount)
	return true
func block(amount):
	enemyController.addBlock(enemyController.Player,amount)
	return true
func consume():
	var theVoid = enemyController.theVoid
	for thing in enemyController.units:
		if thing !=null and thing.tile == consumed:
			thing.die(theVoid)
	if enemyController.Player.tile == consumed:
		enemyController.Player.die(theVoid)
	map.destroyNodeAndSpawn(consumed)
	enemyController.pickConsumed()
	return true
func triggerAll(trigger, argv):
	for card in Play.cards:
		card.Triggered(trigger,argv)
func devoidAll():
	for card in $Voided.cards:
		move("Voided", "Discard",card)
func addStatus(stat, amount, tiles ="Player"):
	if tiles is String and tiles == "Player":
		tiles = [enemyController.Player.tile]
	if tiles == null:
		return false
	for tile in tiles:
		for unit in tile.occupants:
			unit.addStatus(stat, amount)	
func setStatus(stat, amount, tiles = "Player"):
	if tiles is String and tiles  == "Player":
		tiles = [enemyController.Player.tile]
	for tile in tiles:
		for unit in tile.occupants:
			unit.setStatus(stat, amount)
func clearAllStatus(tiles = "Player"):
	if tiles is String and tiles  == "Player":
		tiles = [enemyController.Player.tile]
	for tile in tiles:
		for unit in tile.occupants:
			for stat in unit.status:
				unit.setStatus(stat, 0)
	
func Reaction(amount:float, attacker)-> float:
	if amount < 1:
		return 0
	if $Reaction.cards.size() == 0:
		return amount
	var card = $Reaction.getCard(0)
	setVar(card,"DamageTaken", amount)
	setVar(card,"Attacker", attacker)
	var results = card.Triggered("onReaction",[card])
	if results is GDScriptFunctionState:
		results = yield(results,"completed")
	amount = getVar(card, "DamageTaken")
	displayReaction(card)
	return amount
func voidshift():
	Action("devoidAll",[])
func cardAt(loc,index):
	loc = get_node(loc)
	return loc.getCard(index)	
func save()->Dictionary:
	return{
		"hand": Hand.save(),
		"deck": Deck.save(),
		"discard": Discard.save(),
		"play": Play.save(),
		"voided":$Voided.save(),
		"reaction":$Reaction.save(),
		"energy": self.Energy,
		"consumed":map.nodes.find(consumed)
	}
func loadFromSave(save:Dictionary,parent):
	cardController = self
	Deck = get_node("Deck")
	Hand = get_node("Hand")
	Discard = get_node("Discard")
	Play = get_node("Play")
	Library = get_node("CardLibrary")
	Choice = get_node("Choice")
	var step = Library.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	map = parent.map
	enemyController = parent.enemyController
	

	Hand.loadFromSave(save.hand)
	Deck.loadFromSave(save.deck)
	Discard.loadFromSave(save.discard)
	Play.loadFromSave(save.play)
	$Voided.loadFromSave(save.voided)
	$Reaction.loadFromSave(save.reaction)
	print("Energy:" + str(save.energy) + " "+  str(int(save.energy)))
	Energy = int(save.energy)
	$Energy.updateDisplay()
	consumed = map.nodes[int(save.consumed)]
	print(Hand.cards.size())
	print("AllDone")
func displayReaction(card):
	var displaycard = cardtemplate.instance()
	card.deepcopy(displaycard)
	add_child(displaycard)
	displaycard.moveTo(get_node("Reaction/AnimatedSprite").position- Vector2(100,200), Vector2(.2,.2 ))
	yield(get_tree().create_timer(1),"timeout")
	displaycard.queue_free()
func addhandsize(amount):
	if not amount is int:
		return false
	Hand.maxHandSize+=amount
	return true
