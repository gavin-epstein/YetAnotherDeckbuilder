extends CardLocation
var cardtemplate = preload("res://Card.tscn");
class_name CardLibrary
var CardRng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardRng.randomize()
	pass
	
	
func loadallcards() -> void:
	var f = File.new()
	f.open("res://CardFiles/cards01.txt", File.READ)
	var cardcode = ""
	while not f.eof_reached():
		var line = f.get_line()
		if line =="" and cardcode != "":
			var card = cardtemplate.instance()
			card.loadCardFromString(cardcode)
			self.cards.append(card)
			card.controller = get_parent()
			cardcode = ""
		if not ";" in line:
			line = line+";"
		cardcode+=line
	
func getCardByName(title):
	var ret = cardtemplate.instance()
	for card in cards:
		if card.title == title:
			return card.deepcopy(ret)
	
			
func updateDisplay():
	pass
	
func getRandom(maxRarity:int = 100, types = ["any"]):
	if types.size() ==0:
		types = ["any"]
	var select = []
	for card in cards:
		for type in types:
			if card.hasType(type) and card.rarity <= maxRarity:
				for i in range(card.rarity):
					select.append(card)
	if select.size() == 0:
		return getRandom(maxRarity)
	var ret = cardtemplate.instance()
	return select[CardRng.randi() % select.size()].deepcopy(ret)

func removeUnique(title):
	for card in cards:
		if card.title == title:
			card.rarity = 0;
