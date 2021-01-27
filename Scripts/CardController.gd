extends Node2D

signal resumeExecution
var cardtemplate = preload("res://Card.tscn");
var triggers = {}
var Deck
var Play
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
var enemyController
var lastPlayed
class_name CardController

func Load()-> void:
	Deck = get_node("Deck")
	Hand = get_node("Hand")
	Discard = get_node("Discard")
	Play = get_node("Play")
	Library = get_node("Library")
	Choice = get_node("Choice")
	var step = Library.loadallcards()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("Cards loaded")
	Play.add_card(Library.getCardByName("Adventurer"))
	Play.add_card(Library.getRandomByModifier(["void"]))
	Energy = 3
	map = get_parent().get_node("Map/MeshInstance2D")
	enemyController = get_parent().get_node("EnemyController")
	self.updateDisplay()
	yield(get_tree().create_timer(1),"timeout")
	for _i in range(10):
		print("loot added")
		Deck.add_card(Library.getCardByName("Common Loot"))
		Deck.updateDisplay()
		yield(get_tree().create_timer(.1),"timeout")
	#shuffle()
	step = Action("draw",[5])
	if step is GDScriptFunctionState:
		yield(step,"completed")
	
	
	
func _process(delta: float) -> void:
	inputdelay += delta
	
func Action(method:String, argv:Array,silent = false) -> bool:
	var interrupted = false
	var res
	print(method +" "+ Utility.join(" ", argv))
	if not silent:
		for card in Play.cards:
			if card.Interrupts(method, argv):
				interrupted = true
	if not interrupted:
		
		if self.has_method(method):
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
	updateDisplay()
	return res
	

func draw(x)->bool:
	var results = {}
	for i in range(x):

		if Hand.is_full():
			return i==0

		if Deck.size() == 0:
			if Discard.size() ==0:
				return i==0
			else:
				Action("reshuffle",[])
		var card = Deck.getCard(0)
		move("Deck","Hand",card)
		if card in Hand.cards:
			card.Triggered("onDraw",[x])
			for other in Play.cards:
				other.Triggered("cardDrawn",[card])
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
	lastPlayed = card
	print("Playing " + card.title)
	if card.modifiers.has("unplayable"):
		return false
	if card.cost > Energy:
		return false
	Hand.remove_card(card)
	Play.add_card(card)
	var results = card.Triggered("onPlay",[card])
	if results is GDScriptFunctionState:
		results = yield(results,"completed")
	
	Energy -= card.cost
	updateDisplay()
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
	if card is Dictionary:
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
		var card = Hand.cards[0]
		if not card.modifiers.has("retain"):
			Action("discard", [card, silent]);
		else:
			ind+=1
	return true
	
func discard(card, silent = false):
	if not silent:
		card.Triggered("onDiscard", [card])
	move("Hand", "Discard", card)
	return true
	
func updateDisplay():
	Hand.updateDisplay()
	Discard.updateDisplay()
	Play.updateDisplay()
	Deck.updateDisplay()
	$Voided.updateDisplay()
	$Energy.updateDisplay()
	if enemyController!=null and enemyController.Player != null:
		enemyController.Player.updateDisplay()
	
func cardreward(rarity, count):
	inputAllowed = false
	Choice.generateReward(rarity, count)
	return true

func purge(card):
	if Hand.remove_card(card) or Deck.remove_card(card) or Play.remove_card(card) or Discard.remove_card(card):
		card.queue_free()
		return true
	return false

func takeFocus(item) -> bool:
	if Choice.visible and not item in Choice.cards:
		return false
	if focus == null:
		focus = item
		return true
	elif focus == item:
		return true
	return false

func releaseFocus(item) -> bool:
	if focus == item:
		focus = null
		return true
	return false
	
func create(card, loc):
	loc = get_node(loc)
	var added
	if card is String:
		added = Library.getCardByName(card)
	else:
		added = cardtemplate.instance();
		card.deepcopy(added)
	loc.add_card(added)
	return true
func createByMod(modifiers, loc):
	loc = get_node(loc)
	var added = Library.getRandomByModifier(modifiers)
	
	loc.add_card(added)
	return true
	
func gainEnergy(num):
	Energy += num
	$Energy.updateDisplay()
	return true
	
func voided(card, loc):
	return move(loc, "Voided", card)
	

func endofturn():
	return true

func startofturn():
	return true


func _on_EndTurnButton_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("left_click") and inputdelay > .2:
		inputdelay = 0
		Action("endofturn",[],false)
		#Enemies go here
		enemyController.enemyTurn()
		Action("startofturn", [], false)
		
func select(loc, predicate,message,num = 1):
	inputAllowed = false
	loc = get_node(loc)
	var selectcount = 0
	for card in loc.cards:
		if card.processArgs(predicate, []):
			card.highlight()
			selectcount+=1
	if selectcount == 1:
		for card in loc.cards:
			if card.highlighted:
				cardClicked(card)
				return card
		print("Selectable Card has Moved?")
	elif selectcount == 0:
		return null
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
	selectedCard = null
	$Message/Message.bbcode_text = "[center]"+message+"[/center]"
	$Message.visible = true
	updateDisplay()
	yield(self, "resumeExecution")
	$Message.visible = false
	return selectedCard
func cardClicked(card):
	selectedCard = card
	inputAllowed  = true
	for card in Hand.cards:
		card.dehighlight()
	for card in Play.cards:
		card.dehighlight()
	emit_signal("resumeExecution")
	
func movePlayer(dist,terrains = ["any"]):
	takeFocus(map);
	var tile = map.select(enemyController.Player.tile, dist,"empty", terrains,"Pick a tile to move to");
	if tile is GDScriptFunctionState:
		tile = yield(tile, "completed")
	enemyController.move(enemyController.Player, tile)
	return true
func damage(amount, types, targets,distance):
	var enemies = []
	var tile = enemyController.Player.tile
	var property
	var terrains
	if targets.size() < 3:
		property = "-Player"
	else:
		property = targets[2]
	if targets.size() < 2:
		terrains = ["any"]
	else:
		terrains = targets[1]
	if targets[0] is int:
		for _i in range(targets[0]):
			enemies.append(map.selectRandom(tile,distance,property,terrains))
	elif targets[0] == "all":	
		enemies = map.selectAll(tile,distance,property,terrains)
	elif targets[0]=="any":
		var enemy = map.select(tile,distance,property,terrains,"Pick a target")
		if enemy is GDScriptFunctionState:
			enemy = yield(enemy,"completed")
		enemies.append(enemy)
	
	
	for node in enemies:
		var unit =  node.occupants[0]
		var dmg = unit.takeDamage(amount,types,enemyController.Player)
		if dmg.size() > 1 and dmg[1] == "kill":
			lastPlayed.Triggered("slay",[unit])
		if dmg.size()>0:
			lastPlayed.Triggered("attack",dmg)
			 
	return true

func heal(amount):
	enemyController.Player.heal(amount)
func setVar(card, varname, amount):
	card.vars["$" + varname] = amount
	return true
func addVar(card, varname, amount):
	if card.vars.has("$"  +varname):
		card.vars["$" + varname] = card.vars["$" + varname]  + amount
		return true
	return false
func getVar(card, varname):
	return card.vars("$"+varname);
func summon(unitName, targets, distance) :
	var terrains
	var locs = []
	var tile = enemyController.Player.tile
	if targets.size() < 2:
		terrains = ["any"]
	else:
		terrains = targets[1]
	if targets[0] is int:
		for _i in range(targets[0]):
			locs.append(map.selectRandom(tile,distance,"empty",terrains))
	elif targets[0] == "all":	
		locs = map.selectAll(tile,distance,"empty",terrains)
	elif targets[0]=="any":
		var loc = map.select(tile,distance,"empty",terrains,"Pick a location to summon")
		if loc is GDScriptFunctionState:
			loc = yield(loc,"completed")
		locs.append(loc)
	else:
		assert(false, "invalid Target")
	var unitScene = load(enemyController.get_node("UnitLibrary").getUnitByName(unitName))
	if locs.size() == 0:
		return false
	for node in locs:
		enemyController.addUnit(unitScene.instance(),node)
	return true
func armor(amount):
	enemyController.Player.addArmor(amount)
	return true
func block(amount):
	enemyController.Player.addBlock(amount)
	return true
func consume():
	
	enemyController.theVoid.Consume()
	return true
func triggerAll(trigger, argv):
	for card in Play.cards:
		card.Triggered(trigger,argv)
func devoidAll():
	for card in $Voided.cards:
		move("Voided", "Discard",card)
