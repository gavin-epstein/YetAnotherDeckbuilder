extends Node2D
var Play
var enemyController
var test = false
var hits = []
func _ready() -> void:
	Play = get_node("/root/Scene/CardController/Play")
	enemyController = get_node("/root/Scene/EnemyController")
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
			if test:
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
	test = true
	hits = []
func endTest():
	test = false
	return hits
	
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
