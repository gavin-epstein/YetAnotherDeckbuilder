extends CardLocation
class_name CardLibrary
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
	dir.open("res://CardFiles/")
	print(dir.get_current_dir())
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		
		if fname == "":
			break
		elif fname.ends_with(".txt") or fname.ends_with(".py"):
			var count = loadallcards(dir.get_current_dir()+"/"+fname)
			if count is GDScriptFunctionState:
				count = yield(count,"completed")
			print("Loaded " + str(count) + " from "+fname )

	dir.list_dir_end()
	
func loadallcards(fname) -> int:
	var count = 0
	#print(fname)
	var f = File.new()
	f.open(fname, File.READ)
	if !f.is_open():
		print("Failed to open "+ fname)
		return 0
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
	f.close()
	return count
func loadIcons():
	var dir = Directory.new()
	dir.open("res://Images/Icons/")
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		print(fname)
		if fname == "":
			break
		elif  fname.ends_with(".png.import"):
			fname = fname.substr(0,fname.length()-7)
			print(dir.get_current_dir()+"/"+fname)
			icons[fname.substr(0,fname.length()-4)] = load(dir.get_current_dir()+"/"+fname)

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
	
func getRandom(maxRarity:int = 100, types = []):
	#print("types " +str(types) )
	if types.size() ==0:
		types = ["any"]
	else:
		for i in range(floor(types.size()/7.0)):#more hammers
			types.append("hammer")
		
	var select = []
	for card in cards:
		if card.deleted: #skip removed unique cards
			continue
		for type in types:
			if card.hasType(type) and card.rarity <= maxRarity:
				for _i in range(card.rarity):
					select.append(card)
	if select.size() == 0:
		return getRandom(maxRarity)
	var ret = cardtemplate.instance()
	return select[CardRng.randi() % select.size()].deepcopy(ret)
func getRandomByModifier(mods,raritysensitive = false):
	if mods.size() ==0:
		mods= ["any"]
	var select = []
	for card in cards:
		if  card.deleted:  #skip removed unique cards
			continue
		for mod in mods:
			if card.hasModifier(mod) :
				if (!raritysensitive):
					select.append(card)
				else:
					for _waaah in range(card.rarity):
						select.append(card)
	var ret = cardtemplate.instance()
	if select.size() == 0:
		return false
	return select[CardRng.randi() % select.size()].deepcopy(ret)	
func removeUnique(title):
	for card in cards:
		if card.title == title:
			card.deleted = true
func loadTooltips(fname):
	var f = File.new()
	f.open(fname, File.READ)
	if !f.is_open():
		print("Failed to open "+ fname)
		return 0
	while not f.eof_reached():
		var line = f.get_line()
		if line.find(":") != -1:
			line = line.split(":")
			tooltips[line[0]] = Utility.join(":",Array(line).slice(1, line.size()-1))
	f.close()
func getToolTip(word):
	return tooltips.get(word.to_lower())
func resetDeletedCards():
	for card in cards:
		card.deleted = false
