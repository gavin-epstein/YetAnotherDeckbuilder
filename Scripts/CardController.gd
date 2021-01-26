extends Node2D
enum Results {Interrupt, CardDrawn, CardPlayed, CardDiscarded, EnergySpent, CardMoved, CardPurged, Success, DamageDealt}
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
class_name CardController

func _ready()-> void:
	var screen_size = OS.get_screen_size()
	OS.set_window_size(screen_size)#
	Deck = get_node("Deck")
	Hand = get_node("Hand")
	Discard = get_node("Discard")
	Play = get_node("Play")
	Library = get_node("Library")
	Choice = get_node("Choice")
	Library.loadallcards()
	Play.add_card(Library.getCardByName("Adventurer"))
	Discard.updateDisplay()
	Energy = 3
	$Energy.updateDisplay()
	yield(get_parent(), "ready")
	map = get_parent().get_node("Map/MeshInstance2D")
	enemyController = get_parent().get_node("EnemyController")
	for _i in range(10):
		Deck.add_card(Library.getCardByName("Common Loot"))
	shuffle()
	Action("draw",[5])
	
	
func _process(delta: float) -> void:
	inputdelay += delta
	
func Action(method:String, argv:Array, silent = false) -> Dictionary:
	var interrupted = false
	var results = {}
	print(method + Utility.join(" ", argv))
	if not silent:
		for card in Play.cards:
			if card.Interrupts(method, argv):
				interrupted = true
				Utility.addtoDict(results, Results.Interrupt , card)
	if not interrupted:
		
		if self.has_method(method):
			var res =  self.callv(method, argv)
			if res is GDScriptFunctionState:
				res = yield(res,"completed")
			Utility.extendDict( results , res)
		else:
			print("attempting to " + method)
		if not silent and results.has(Results.Success):
			#look through play, if card is removed from play don't increment index
			var ind = 0
			while Play.cards.size() > ind:
				var card = Play.cards[ind]
				var res = card.Triggered(method, argv, results)
				if res is GDScriptFunctionState:
					res = yield(res,"completed")
				Utility.extendDict(results,res)
				if card in Play.cards:
					ind+=1
	updateDisplay()
	return results
	

func draw(x)->Dictionary:
	var results = {}
	for _i in range(x):
		if Hand.is_full():
			Utility.addtoDict(results, Results.Interrupt, "Hand Full")
			break
		if Deck.size() == 0:
			if Discard.size() ==0:
				Utility.addtoDict(results, Results.Interrupt, "Deck Empty")
				return results
			else:
				Action("reshuffle",[])
		var card = Deck.getCard(0)
		Deck.remove_card_at(0)
		Hand.add_card_at(card, 0)
		Utility.extendDict(results, card.Triggered("onMove", ["Deck", "Hand"], results))
		Utility.extendDict(results, card.Triggered("onDraw", [], results))
		Utility.addtoDict(results, Results.CardDrawn, card)
		results[Results.Success] = true;
	return results

func reshuffle()->Dictionary:
	if Discard.size()==0:
		return {Results.Interrupt:["Discard Empty"]}
	Deck.cards +=Discard.cards
	Deck.cards.shuffle()
	Discard.cards = []
	return {Results.Success:true}
func shuffle()->Dictionary:
	if Deck.size() ==0:
		return {Results.Interrupt:["Deck Empty"]}
	Deck.cards.shuffle()
	return {Results.Success:true}

func play(card)->Dictionary:
	print("Playing " + card.title)
	if card.modifiers.has("unplayable"):
		return {Results.Interrupt:["unplayable"]}
	if card.cost > Energy:
		return{Results.Interrupt:["outOfEnergy"]}
	Hand.remove_card(card)
	Play.add_card(card)
	var results = card.Triggered("onPlay",[card],{})
	if results is GDScriptFunctionState:
		results = yield(results,"completed")
		
	Energy -= card.cost
	$Energy.updateDisplay()
	Utility.addtoDict(results, Results.CardPlayed, card)
	Utility.addtoDict(results, Results.EnergySpent, card.cost)
	results[Results.Success] = true;
	Play.updateDisplay()
	return results
	

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
func move(loc1, loc2, card):
	if card is Dictionary:
		return card
	loc1 = get_node(loc1)
	loc2 = get_node(loc2)
	if loc1.remove_card(card):
		loc2.add_card(card)
		return {Results.CardMoved:[loc1,loc2,card], Results.Success:true}
	return {Results.Interrupt:"Card Not Found"}	
func setEnergy(num):
	Energy = num
	$Energy.updateDisplay()
	return {Results.Success:true}
func discardAll(silent = false):
	var ind =0;
	while Hand.cards.size() >ind:
		var card = Hand.cards[0]
		if not card.modifiers.has("retain"):
			Action("discard", [card, silent]);
		else:
			ind+=1
	return {Results.Success:true}
	
func discard(card, silent = false):
	if not silent:
		card.Triggered("onDiscard", [card],{})
	move("Hand", "Discard", card)
	return {Results.Success:true}
	
func updateDisplay():
	Hand.updateDisplay()
	Discard.updateDisplay()
	Play.updateDisplay()
	Deck.updateDisplay()
	$Voided.updateDisplay()
	$Energy.updateDisplay()
	if enemyController.Player != null:
		enemyController.Player.updateDisplay()
	
func cardreward(rarity, count):
	inputAllowed = false
	Choice.generateReward(rarity, count)
	return {Results.Success:true}

func purge(card):
	if Hand.remove_card(card) or Deck.remove_card(card) or Play.remove_card(card) or Discard.remove_card(card):
		var ret = {Results.CardPurged : [card.title],Results.Success:true }
		card.queue_free()
		return ret
	return {Results.Interrupt:"Card Not Found"}

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
	return {Results.Success:true}

func gainEnergy(num):
	Energy += num
	$Energy.updateDisplay()
	return {Results.Success:true}
	
func voided(card, loc):
	return move(loc, "Voided", card)
	

func endofturn():
	return {Results.Success:true}

func startofturn():
	return {Results.Success:true}


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
					if not prototype.isIndentical(card):
						alltheSame = false
						break
		if alltheSame:
			cardClicked(prototype)
			return prototype
	selectedCard = null
	$Message/Message.bbcode_text = "[center]"+message+"[/center]"
	$Message.visible = true
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
	return {Results.Success: true}
func damage(amount, types, targets,distance):
	var enemies = []
	var tile = enemyController.Player.tile
	var property
	var terrains
	if targets.size() < 3:
		property = "notPlayer"
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
	
	var results = {Results.Success:true}
	for node in enemies:
		var dmg = node.occupants[0].takeDamage(amount,types,enemyController.Player)
		Utility.extendDict(results, {Results.DamageDealt:dmg})
	return results

func heal(amount):
	enemyController.Player.heal(amount)

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
		return {Results.Interrupt: "No Valid Location"}
	for node in locs:
		enemyController.addUnit(unitScene.instance(),node)
	return {Results.Success: true}
func armor(amount):
	enemyController.Player.addArmor(amount)
	return {Results.Success:true}
func block(amount):
	enemyController.Player.addBlock(amount)
	return {Results.Success:true}
