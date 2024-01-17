extends Node2D
const WorkshopTile = preload("res://Dreams/WorkshopTile.tscn")
var startypes = ["rage", "water", "attack", "fire", "blood", "cloud", "cactus", "knife", "avian", "light", "starter", "food", "shadow", "dodge", "dream", "shield", "ice", "earth", "electric", "mechanical", "death", "loot", "wind", "movement"]
var endtypes = ["kinetic", "rage", "attack", "fire", "blood", "cloud", "ritual", "cactus", "knife", "avian", "light", "food", "shadow", "dodge", "dream", "shield", "ice", "steel", "electric", "loot", "wind", "movement"]
var starts = []
var ends = []
var grid = []
var gridwidth = 6
var gridheight=7
const tilesize=1080/7
var images = {}
var cardimages={}
var icons = {}
var cardController
var Library
var enemyController = null
const cardtemplate = preload("res://Card.tscn");
const tileoffset = Vector2(375,0)
func _ready():
	randomize()
	Load()

func Load():
	loadIcons()
	loadImages()
	self.cardController = get_parent()
	self.Library = cardController.Library
	#$Map/Clickbox.rect_size = Vector2(1920,1080)
	for type in ["bent", "3way", "4way", "straight", "doublediagonal", "inputplatform", "outputplatform"]:
		images[type] = load("res://Images/Puzzles/EnchantersPipes/" + type + ".png")
	#$CardBox.position = Vector2(gridwidth*tilesize + 20, 10)
	for x in range(0,gridwidth):
		var col = []
		for y in range(0, gridheight):
			var tile = WorkshopTile.instance()
			var type = Utility.choice(images.keys())
			while type in ["inputplatform", "outputplatform"]:
				type = Utility.choice(images.keys())
		#	tile.workshop = self
			$Map.add_child(tile)
		#	tile.scale = Vector2(.5, .5)
			tile.gridx = x
			tile.gridy = y
			tile.scramble()
			tile.setType(type, images[type])
			var tilec = tilesize*Vector2(x,y) + tileoffset
			var nextc = tilec+Vector2(tilesize, tilesize)
			var topleft = getEllipse(tilec.x, tilec.y)
			var topright = getEllipse(nextc.x, tilec.y)
			var bottomleft = getEllipse(tilec.x, nextc.y)
			var bottomright = getEllipse(nextc.x, nextc.y)
			tile.setRect(topleft, topright, bottomleft, bottomright)
			#tile.position = Vector2(tilesize*x, tilesize*y)+.5*Vector2(tilesize, tilesize)
			var tiles = []
			tiles.append(tile)
			if type == "doublediagonal":
				tile = WorkshopTile.instance()
				tile.type = "doublediagonal"
				
#				tile.workshop = self
				$Map.add_child(tile)
				tile.face((tiles[0].facing + 180) % 360)
				tile.gridx = x
				tile.gridy = y
				tile.setType(type, images[type])
				tilec = tilesize*Vector2(x,y) + tileoffset
				nextc = tilec+Vector2(tilesize, tilesize)
				topleft = getEllipse(tilec.x, tilec.y)
				topright = getEllipse(nextc.x, tilec.y)
				bottomleft = getEllipse(tilec.x, nextc.y)
				bottomright = getEllipse(nextc.x, nextc.y)
				tile.setRect(topleft, topright, bottomleft, bottomright)
				tiles.append(tile)
			col.append(tiles)
		grid.append(col)
	#make starts and ends
#	var startypes = cardController.Library.icons.keys().duplicate()
#	var endtypes = startypes.duplicate()
#	for thing in ["assassin", "summon", "fungal", "ritual", "hammer", "kinetic", "potion", "steel"]:
#		startypes.erase(thing)
#	for thing in ["assassin", "hammer", "mechanical", "potion", "starter", "summon", "water", "earth", "fungal", "death"]:
#		endtypes.erase(thing)


#	print(startypes)
#	print(endtypes)
	for i in range (3):
		var x = randi()%grid.size()
		var y = randi()%grid[0].size()
		var tiles = grid[x][y]
		tiles[0].setType("outputplatform", images.outputplatform)
		ends.append(tiles[0])
		if tiles.size()>1:
			tiles[1].queue_free()
		var tile = tiles[0]
		grid[x][y] = [tile]
		tile.cardtype = Utility.choice(endtypes)
		tile.get_node("typeicon").texture = icons[tile.cardtype]
		startypes.erase(tile.cardtype)
		endtypes.erase(tile.cardtype)
	for i in range (3):
		var x = randi()%grid.size()
		var y = randi()%grid[0].size()
		var tiles = grid[x][y]
		if tiles[0] in ends:
			continue
		tiles[0].setType("inputplatform", images.inputplatform)
		starts.append(tiles[0])
		if tiles.size()>1:
			tiles[1].queue_free()
		var tile = tiles[0]
		grid[x][y] = [tile]
		tile.cardtype = Utility.choice(startypes)
		tile.get_node("typeicon").texture = icons[tile.cardtype]
		startypes.erase(tile.cardtype)
		endtypes.erase(tile.cardtype)
	for row in grid:
		for tiles in row:
			for tile in tiles:
				if randf()<.6:
					tile.setCost(randi()%4 - 1)
	check()
func check():
	$CardBox.clear()
	var endsreached = bfs(starts)
	for end in endsreached:
		var endtype = end.cardtype
		var cost = 0
		var duration = 0
		var trail:Node2D  = end
		while trail.prev !=  trail:
			cost+=trail.cost
			trail.modulate = Color(1,.5,.5)
			trail = trail.prev
			duration+=1
		var starttype = trail.cardtype
		var card = cardController.Library.cardtemplate.instance()
		card.controller = self.cardController	
		var cardtext = generateEnchant(starttype, endtype,max(0,cost), duration)
		card.loadCardFromString(cardtext)
		generateImage(starttype, endtype, card)
		$CardBox.add_card(card)
	$CardBox.updateDisplay()
	
	
func bfs(starts):
	for row in grid:
		for tiles in row:
			for tile in tiles:
				tile.reset()
	var endsreached = []
	var stack = starts.duplicate()
	for start in starts:
		start.prev = start
	while stack.size() > 0:
		#yield(get_tree().create_timer(.2),"timeout")
		var cur = stack.pop_front()
		for coords in [Vector2(cur.gridx + 1,cur.gridy), Vector2(cur.gridx - 1,cur.gridy),Vector2(cur.gridx ,cur.gridy+1), Vector2(cur.gridx,cur.gridy-1)       ]:
			
			if coords.x >= 0 and coords.x < grid.size() and coords.y >=0 and coords.y <grid[0].size():
				var neighs  = grid[int(coords.x+.01)][int(coords.y+.01)]
				var fromdir = getDirection(cur, cur.prev)
				for neigh in neighs:
					if  neigh in stack or neigh.prev!=null:
						continue
					var todir = getDirection(cur, neigh)
					if cur.connects(todir) and neigh.connects((todir + 180)%360):
						stack.append(neigh)
						neigh.prev  = cur
						neigh.modulate = Color(.5, 1, .5)
						if neigh in ends:
							endsreached.append(neigh)
							#print("Connect!")
	return endsreached
	
		
static func getDirection(fromtile, totile):
	var from = Vector2(fromtile.gridx, fromtile.gridy)
	var to = Vector2(totile.gridx, totile.gridy)
	var dif:Vector2 = to-from
	if dif.x < -0.5:
		return 270
	if dif.x > .5:
		return 90
	if dif.y > .05:
		return 180
	return 0


#func _on_Clickbox_gui_input(event: InputEvent) -> void:
#	if event.is_action_pressed("left_click"):
#		var coords = event.position
#		coords = getEllipse(coords.x, coords.y)
#		var tilecoords = (coords) /tilesize
#		if tilecoords.x < 0 or tilecoords.y < 0  or tilecoords.x > grid.size() or tilecoords.y > grid[0].size():
#			return
#		for tile in grid[int(tilecoords.x)][int(tilecoords.y)]:
#			tile.spin()
#		check()
func tileclicked(intile):
	for tile in grid[int(intile.gridx)][int(intile.gridy)]:
		tile.spin()
	check()
func loadImages():
	var dir = Directory.new()
	dir.open("res://Images/CardArt/Dreams/Enchanters")
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		#print(fname)
		if fname == "":
			break
		elif  fname.ends_with(".png.import"):
			fname = fname.substr(0,fname.length()-7)
			#print(dir.get_current_dir()+"/"+fname)
			cardimages[fname.substr(0,fname.length()-4)] = load(dir.get_current_dir()+"/"+fname).get_data()
	dir.list_dir_end()

func loadIcons():
	var dir = Directory.new()
	dir.open("res://Images/Icons/")
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		if fname == "":
			break
		elif  fname.ends_with(".png.import"):
			fname = fname.substr(0,fname.length()-7)
			print(dir.get_current_dir()+"/"+fname)
			icons[fname.substr(0,fname.length()-4)] = load(dir.get_current_dir()+"/"+fname)

	dir.list_dir_end()

static func generateEnchant(intype, outype, cost, duration):
	var vars = {}
	var text = []
	var triggers = []
	var titlestart=""
	var titleend=""
	var endtriggers = []
	var triggerkey=""
	var condition=true
	var result=""
	if intype  == "attack":
		text.append("When you play an attack")
		triggerkey = "play"
		condition = 'hastype(argv[0], "attack")'
		titleend = "Brawl"
	elif intype == "avian":
		text.append("When you summon a unit")
		triggerkey = "summon"
		condition = "true"
		titleend = "Birds"
	elif intype == "blood":
		text.append("When you lose health")
		triggerkey = "unheal"
		condition = "true"
		titleend = "Wound"
	elif intype == "cactus":
		text.append("When you gain thorns")
		triggerkey = "addStatus"
		condition = 'argv[0]="thorns"'
		titleend = "Spikes"
	elif intype == "cloud":
		text.append("Every $totalcount cards you discard, $count remaining,")
		vars["totalcount"] = 2
		vars["count"] = 2
		triggers.append("trigger(discard, do(addVar(self, count, -1)))")
		endtriggers.append("trigger(discard, if(($count=0),(do(setVar(self, count, 0)))))")
		triggerkey = "discard"
		condition = '$count=0'
		titleend = "Haze"
	elif intype == "dodge":
		text.append("When you dodge an attack")
		triggerkey = "dodged"
		condition = 'true'
		titleend = "Acrobatics"
	elif intype == "dream":
		text.append("When you randomly generate a card")
		triggerkey = "dream"
		condition = "true"
		titleend = "Dream"
	elif intype == "death":
		text.append("When a unit dies")
		triggerkey = "death"
		condition = "true"
		titleend = "Mortality"
	elif intype == "earth":
		text.append("When you draw an unplayable card")
		triggerkey = "cardDrawn"
		condition = "hasModifier(argv[0],unplayable)"
		titleend = "Soil"
	elif intype == "electric":
		text.append("When you deplete")
		triggerkey = "deplete"
		condition = "true"
		titleend = "Capacitor"
	elif intype =="fire":
		text.append("When you burn a card")
		triggerkey = "burn"
		condition = "true"
		titleend = "Flame"
	elif intype =="food":
		text.append("When you heal")
		triggerkey = "heal"
		condition = "true"
		titleend = "Delicacy"
	elif intype =="ice":
		text.append("When you freeze a card")
		triggerkey = "addModifier"
		condition = 'argv[1]="frozen"'
		titleend = "Frost"
	elif intype == "kinetic":
		text.append("When you push or pull any units")
		triggerkey = "moveUnits"
		condition = "true"
		titleend = "Dance"
	elif intype == "knife":
		text.append("When you play a kitchen knife")
		triggerkey = "play"
		condition = "hasModifier(argv[0],kitchenknife)"
		titleend = "Knives"
	elif intype == "light":
		text.append("When you gain energy")
		triggerkey = "gainEnergy"
		condition = "true"
		titleend = "Gleam"
	elif intype == "loot":
		text.append("When you recieve a card reward")
		triggerkey = "cardreward"
		condition = "true"
		titleend = "Treasure"
	elif intype == "mechanical":
		text.append("At the start of your turn")
		triggerkey = "startofturn"
		condition = "true"
		titleend = "Gears"
	elif intype == "movement":
		text.append("When you move")
		triggerkey = "movePlayer"
		condition = "true"
		titleend = "Sprint"
	elif intype == "rage":
		text.append("When you gain rage")
		triggerkey = "addStatus"
		condition = 'argv[0]="rage"'
		titleend = "Wrath"
	elif intype == "shadow":
		text.append("Every $totalcount cards you play, $count remaining,")
		vars["totalcount"] = 4
		vars["count"] = 4
		triggers.append("trigger(play, do(addVar(self, count, -1)))")
		endtriggers.append("trigger(play, if(($count=0),(do(setVar(self, count, 0)))))")
		triggerkey = "play"
		condition = '$count=0'
		titleend = "Occlusion"
	elif intype =="shield":
		text.append("Every time you gain at least 3 block")
		triggerkey = "block"
		condition = 'argv[0]>2'
		titleend = "Buckler"
	elif intype  == "starter":
		text.append("When you play a starter card")
		triggerkey = "play"
		condition = 'hastype(argv[0], "starter")'
		titleend = "Simplicity"
	elif intype  == "water":
		text.append("When you shuffle your deck")
		triggerkey = "shuffle"
		condition = 'true'
		titleend = "Waves"
	elif intype == "wind":
		text.append("When you draw $count more cards, including at the start of your turn,")
		vars["totalcount"] = 7
		vars["count"] = 7
		triggers.append("trigger(cardDrawn, do(addVar(self, count, -1)))")
		endtriggers.append("trigger(cardDrawn, if(($count=0),(do(setVar(self, count, 0)))))")
		triggerkey = "cardDrawn"
		condition = '$count=0'
		titleend = "Wind"
	
	
	
	
	
	
	
	if outype == "attack":
		text.append("deal $Damage stab damage range $Range")
		vars["Damage"] = 5
		vars["Range"] = 2
		result =  "do(damage, ($Damage,(stab),(any),$Range))"
		titlestart = "Aggresive"
	elif outype =="avian":
		vars["Range"] = 3
		text.append("summon a swallow in range $Range")
		result = "do(summon('Barn Swallow',(any),$Range))"
		titlestart = "Feathered"
	elif outype =="blood":
		vars["Bleed"] = 1
		text.append("Lose $Bleed health")
		result = "do(unheal($Bleed))"
		titlestart = "Bloody"
	elif outype =="cactus":
		vars["Thorns"] = 2
		text.append("gain $Thorns thorns")
		result = "do(addStatus(thorns,$Thorns))"
		titlestart = "Prickly"
	elif outype =="cloud":
		text.append("discard a card from your hand")
		result = 'do(discard,((select(Hand,true,"pick a card to discard"))))'
		titlestart = "Misty"
	elif outype == "dodge":
		vars["Dodge"] = 15
		text.append("gain $Dodge dodge")
		result = "do(addStatus(dodge,$Dodge))"
		titlestart = "Avoidant"
	elif outype =="dream":
		text.append("add a randomly generated temporary card to your hand")
		result = 'do(dream(Hand))'
		titlestart = "Mind"
	elif outype =="electric":
		vars["Charge"] = 1
		text.append("charge $Charge")
		result = 'do(charge($Charge))'
		titlestart = "High Voltage"
	elif outype =="fire":
		text.append("burn a card from your hand")
		result = 'do(burn,((select(Hand,true,"pick a card to burn"))))'
		titlestart = "Burning"
	elif outype == "food":
		vars["Heal"] = 2
		text.append("heal $Heal")
		result = 'do(heal($Heal))'
		titlestart = "Delicious"
	elif outype == "ice":
		text.append("freeze a card from your hand")
		result = 'do(addModifier( (select(Hand,true,"pick a card to freeze")),frozen))'
		titlestart = "Gelid"
	elif outype == "kinetic":
		vars["MoveOther"] = 1
		text.append("push a unit $MoveOther tile twice")
		result = "repeat( (do(moveUnits((any),40,Player,away,$MoveOther))), 2)"
		titlestart = "Repulsive"
	elif outype == "knife":
		text.append("add a random kitchen knife to your hand")
		result = "do(createByMod,(('kitchenknife'), Hand,self))"
		titlestart = "Sharpened"
	elif outype == "light":
		vars["Energy"] = 1
		text.append("gain $Energy energy")
		result = 'do(gainEnergy($Energy))'
		titlestart = "Scintillating"
	elif outype == "loot":
		text.append("choose 1 of 3 cards to add to your hand")
		result = 'do(cardReward(100,3))'
		titlestart = "Golden"
	elif outype == "movement":
		vars["Move"] = 2
		text.append("move $Move")
		result = 'do(movePlayer($Move))'
		titlestart = "Nimble"
	elif outype =="rage":
		vars["Status"] = 1
		text.append("gain $Status rage")
		result = "do(addStatus(rage,$Status))"
		titlestart = "Angry"
	elif outype == "shadow":
		text.append("add a random shadow to your hand")
		result = "do(createByMod,(('shadow'), Hand,self))"
		titlestart = "Gloomy"
	elif outype == "shield":
		vars["Block"] = 4
		text.append("block $Block")
		result = 'do(block($Block))'
		titlestart = "Fortified"
	elif outype == "steel":
		vars["Armor"] = 1
		text.append("gain $Armor armor")
		result = 'do(armor($Armor))'
		titlestart = "Armor Plated"
	elif outype == "wind":
		vars["Draw"] = 1
		text.append("draw $Draw")
		result = 'do(draw($Draw))'
		titlestart = "Winged"
	elif outype == "ritual":
		text.append("add a random sigil to play")
		result ="do(createByMod,(('sigil'), Play,self))"
		titlestart = "Rune-scribed"
	
	var cardtext = ""
	
	cardtext += Utility.join(";", triggers) + ";"
	for key in vars:
		cardtext+= "$" + key + "=" + str(vars[key]) + ";"
	cardtext += 'types( '+intype + ", "+ outype + ", " + "enchantment" +  ");"
	cardtext+= 'cost(' + str(cost) + ");"
	cardtext+='trigger(' +triggerkey + ", if(( "  + condition +"),(" + result + ")));"
	cardtext += Utility.join(";", endtriggers) + ";"
	if condition != "true":
		condition = "(" + condition + ")"
	cardtext+='removetrigger(' + triggerkey + ", " + condition + ", " + str(duration) +');'
	cardtext+='rarity(0);'
	cardtext+='title(' + titlestart + " " + titleend +');'
	cardtext += 'text("' + Utility.join(" ",text) + '");'
	cardtext += 'modifiers(enchanters);'
	
	return cardtext
	
func generateImage(intype, outtype, card):
	var im = Image.new();
	im.create(1300,1080,false,Image.FORMAT_RGBA8)
	im.fill(Color(0,0,0,1))
	if outtype+"back" in cardimages.keys():
		var element = cardimages[outtype+"back"]
		im.blend_rect(element,Rect2(0,0,1300,1080),Vector2(0,0))
	if intype+"front" in cardimages.keys():
		var element = cardimages[intype+"front"]
		im.blend_rect(element,Rect2(0,0,1300,1080),Vector2(0,0))
	card.image = ImageTexture.new()
	card.image.create_from_image(im);
	card.imageloaded = false
	
func getEllipse(x, y):
	return Vector2(x,y)
	var h = 1080
	var w = 1920/2
	var p = 2.0* y/h- .5
	var yoff =200.0;
	var wx=(x-w)/w
	var outy =(p+1)*h/2  -yoff*( abs(p)/p *sqrt(p*p - p*p*wx*wx ))
	outy = (outy-h/2)*1.25 + h/2
	return Vector2(x-20,outy)


func createcards():
	for card in $CardBox.cards:
		cardController.create(card, "Hand")
	cardController.updateDisplay()
	get_parent().remove_child(self)
	self.queue_free()


func recoverImage(card):
	
	for t1 in card.types:
		for t2 in card.types:
			var text = generateEnchant(t1,t2,0,0)
			if text.find(card.title)!=-1:
				generateImage(t1,t2,card)
				return
	
