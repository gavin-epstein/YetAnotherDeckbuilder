extends Node2D
var Play
var enemyController
var cardController
var test = false
const testMethods = ["Attack","addArmor","addBlock",
					"gainStrength","gainMaxHealth",
					"heal","Summon","setVar","addVar",
					"getStatus","setStatus","clearAllStatus",
					"move","reshuffle","shuffle","draw",
					"play","setEnergy","gainEnergy","discard",
					"discardAll","cardreward","purge","create",
					"createByMod","voided","endofturn","startofturn",
					"movePlayer","damage","moveUnits","summon",
					"armor","block","consume","addStatus"
					]
var hits = []
func _ready() -> void:
	Play = get_node("/root/Scene/CardController/Play")
	enemyController = get_node("/root/Scene").enemyController
	cardController = get_node("/root/Scene").cardController
func Action(method:String, argv:Array,silent = false) -> bool:
	var interrupted = false
	var stoppable = silent
	if silent is Array:
		stoppable = silent[1]
		silent = silent[0]
	var res
	#print(method +" "+ Utility.join(" ", argv))
	if not stoppable:
		for card in Play.cards:
			if card.Interrupts(method, argv):
				interrupted = true
				print(method+str(argv) + " interrupted by " + card.title)
	if not interrupted:
		
		if self.has_method(method):
			if test and method in testMethods:
				hits.append(method)
			else:
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
	if self.has_method("updateDisplay"):
		self.call("updateDisplay")
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
	if card == null:
		return false
	card.vars["$" + varname] = amount
	return true
func addVar(card, varname, amount):
	if card == null:
		return false
	if card.vars.has("$"  +varname):
		card.vars["$" + varname] = card.vars["$" + varname]  + amount
		return true
	return false
func getVar(card, varname):
	if card == null:
		return false
	return card.vars["$"+varname];
