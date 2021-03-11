extends CardLocation
var cardtemplate = preload("res://Card.tscn");

var CardRng = RandomNumberGenerator.new()
var icons = {}
var tooltips = {}
var loaded = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardRng.randomize()
	pass
	
func Load():
	if loaded:
		return true
	loaded = true
	loadIcons()
	loadTooltips("res://CardToolTips/cardtooltips.txt")
	var dir = Directory.new()
	dir.open("res://Cardfiles/")
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		
		if fname == "":
			break
		elif fname.ends_with(".txt"):
			var count = loadallcards(fname)
			if count is GDScriptFunctionState:
				count = yield(count,"completed")
			print("Loaded " + str(count) + " from "+fname )

	dir.list_dir_end()
	
func loadallcards(fname) -> int:
	var count = 0
	var f = File.new()
	f.open("res://CardFiles/"+fname, File.READ)
	var cardcode = ""
	while not f.eof_reached():
		var line = f.get_line()
		if line!= "" and line[0] == "#":
			continue
		if line =="" and cardcode != "":
			var card = cardtemplate.instance()
			card.controller = get_parent()
			card.loadCardFromString(cardcode)
			self.cards.append(card)
			count+=1
			cardcode = ""
			yield(get_tree().create_timer(.001), "timeout")
			
		if not ";" in line and line!="":
			line = line+";"
		cardcode+=line
	return count
func loadIcons():
	var dir = Directory.new()
	dir.open("res://Images/Icons/")
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		if fname == "":
			break
		elif fname.ends_with(".png"):
			print(fname.substr(0,fname.length()-4))
			icons[fname.substr(0,fname.length()-4)] = load("res://Images/Icons/"+fname)

	dir.list_dir_end()

	
func getCardByName(title):
	var ret = cardtemplate.instance()
	for card in cards:
		if card.title == title:
			card.deepcopy(ret)
			ret.updateDisplay()
			return ret
			
func updateDisplay():
	pass
	
func getRandom(maxRarity:int = 100, types = ["any"]):
	if types.size() ==0:
		types = ["any"]
	types.erase("attack")
	types.erase("movement")
	var select = []
	for card in cards:
		for type in types:
			if card.hasType(type) and card.rarity <= maxRarity:
				for _i in range(card.rarity):
					select.append(card)
	if select.size() == 0:
		return getRandom(maxRarity)
	var ret = cardtemplate.instance()
	return select[CardRng.randi() % select.size()].deepcopy(ret)
func getRandomByModifier(mods):
	if mods.size() ==0:
		mods= ["any"]
	var select = []
	for card in cards:
		for mod in mods:
			if card.hasModifier(mod):
				select.append(card)
	var ret = cardtemplate.instance()
	if select.size() == 0:
		return false
	return select[CardRng.randi() % select.size()].deepcopy(ret)	
func removeUnique(title):
	for card in cards:
		if card.title == title:
			card.rarity = 0;
			card.modifiers = {};
func loadTooltips(fname):
	var f = File.new()
	f.open(fname, File.READ)
	while not f.eof_reached():
		var line = f.get_line()
		if line.find(":") != -1:
			line = line.split(":")
			tooltips[line[0]] = Utility.join(":",Array(line).slice(1, line.size()-1))
func getToolTip(word):
	return tooltips.get(word.to_lower())
