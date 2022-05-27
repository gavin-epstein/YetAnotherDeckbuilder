extends Node
var markov={}
var images=[]
func Load():
	var f = File.new()
	f.open("res://Dreams/model.txt", File.READ)
	if !f.is_open():
		print("Failed to open dreams model")
		return 0
	var text = ""
	if not f.eof_reached():
		 text = f.get_line()
	var keychunks = text.split("=", false)
	for keychunk in keychunks:
		var key = keychunk.split("~")[0]
		var vals = keychunk.split("~")[1].split(",", false)
		var valsdict = {}
		for val in vals:
			valsdict[val.split(":")[0]] =int(val.split(":")[1])
		markov[key] = valsdict
	var dir = Directory.new()
	dir.open("res://Images/CardArt/Dreams/Abstract/")
	print(dir.get_current_dir())
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		
		if fname == "":
			break
		elif fname.ends_with(".png"):
			images.append(load(dir.get_current_dir()+"/"+fname).get_data());

	dir.list_dir_end()
		

func generateCard(card:Card, temporary= true):
	var text = []
	var triggers = []
	var vars = {}
	var types = {}
	var modifiers={}
	if temporary:
		modifiers["temporary"]=true
	for i in range(min(r(), 3)):
		var list = generateTrigger()
		text = text+list[0]
		triggers = triggers+list[1]
		Utility.extendDict(vars, list[2])
		Utility.extendDict(types, list[3])
		Utility.extendDict(modifiers, list[4])
		
	var cardtext = ""
	
	cardtext += Utility.join(";", triggers) + ";"
	for key in vars:
		cardtext+= "$" + key + "=" + str(vars[key]) + ";"
	cardtext += 'types( '+Utility.join(", ", types.keys()) + ");"
	cardtext+= 'cost(' + str(min(r()-1, r())) + ");"
	cardtext+='removetrigger(endofturn, true,'+str(r())+');'
	cardtext+='rarity(0);'
	cardtext+='title(' + generateTitle() +');'
	cardtext += 'modifiers( '+Utility.join(", ", modifiers.keys()) + ");"
	cardtext += 'text("' + Utility.join(" .\\n",text) + '");'
	#print(cardtext)
	card.loadCardFromString(cardtext)
	generateImage(card)
func generateTitle():
	var title = ""
	var key = Utility.choice(markov.keys())
	for i in range(40):
		var val  = _getNextMarkov(key)
		key = key.substr(1) + val
		title +=val
	title = title.split("|")[1]
	if len(title) > 18:
		title = title.substr(0, 18)
	return title
func _getNextMarkov(key):
	var possible = markov[key]
	var total = 0
	for val in possible.values():
		total+=int(val)
	var choice = randi()%total
	total = 0
	for pkey in possible.keys():
		total+= possible[pkey]
		if total > choice:
			return pkey

	
		
	
func generateTrigger():
	var text = []
	var triggers = []
	var vars = {}
	var types ={}
	var modifiers = {}
	var options = ["burn","attack", "burnself", "permafrost","block","thorns", "freeze", "blood", "gainEnergy", "draw", "sigil"]
	var opt = Utility.choice(options)
	
	if opt =="burn":
		vars["Times"] = r()
		var loc = getLoc()
		triggers.append("trigger(onPlay, repeat( (do(voided((select("+loc+',(! hasModifier(self,"eternal")),"Pick a card to burn")),'+loc+"))),$Times))")
		text.append("Burn $Times non eternal card(s) from "+_LocToString(loc));
		types["fire"] = true;
	elif opt =="burnself":
		text.append("Burn this card")
		triggers.append("trigger(onPlay,do(voided(self, Play)))")
		types["fire"] = true;
	elif opt =="attack":
		vars["Damage"] = ceil(2*randomPositiveFloat()+randomPositiveFloat());
		vars["Range"] = r()
		var damagetype = Utility.choice(["fire","crush","slash","stab", "piercing", "storm", "hail", "shadow"])
		triggers.append("trigger(onPlay, do(damage, ($Damage,("+damagetype+"),(any),$Range)))")
		text.append("Deal $Damage "+damagetype+" damage, range $Range")
		types["attack"] = true;
	elif opt == "permafrost":
		modifiers["permafrost"] = true
		types["ice"] = true
		text.append("Permafrost")
	elif opt == "block":
		vars["Block"] = r()
		triggers.append("trigger(onPlay,do(block($Block)))");
		text.append("Block $Block");
	elif opt == "thorns":
		vars["Thorns"] = r()
		text.append("Gain $Thorns thorns")
		triggers.append("trigger(onPlay,do(addStatus(thorns,$Thorns)))")
		types["cactus"]=true
	elif opt == "freeze":
		triggers.append('trigger(onPlay,do(addModifier( (select(Hand,true,"pick a card to freeze")),frozen)))');
		text.append("Freeze a card in your hand")
		types["ice"]=true
	elif opt == "ritual":
		types["ritual"]==true
	elif opt == "bleed":
		vars["Blood"] = r()
		triggers.append('trigger(onPlay,do(unheal($Blood)))')
		text.append("Lose $Bleed health")
		types["blood"]= true
	elif opt == "gainEnergy":
		vars["Energy"] = r()
		triggers.append('trigger(onPlay, do(gainEnergy($Energy)));')
		text.append('Gain $Energy energy');
		types["light"]=true
	elif opt == "draw":
		vars["Draw"] = r()
		triggers.append('trigger(onPlay, do(draw($Draw)));')
		text.append('Draw $Draw');
		types["wind"]=true
	elif opt == "sigil":
		triggers.append('trigger(onPlay, do(createByMod((sigil), Play)))')
		text.append("Add a random sigil to play")
		types["ritual"] = true
	return [text, triggers, vars, types, modifiers];
static func getLoc():
	var list = ["","Hand","Play","Deck", "Discard", "Voided"]
	var r = r()
	while r >= len(list):
		r=r()
	return list[r]
	
func _LocToString(loc):
	if loc == "Voided":
		return "the Burn Pile"
	elif loc == "Play":
		return "Play"
	
	return "your " + loc
	
func generateImage(card):
	var im = Image.new();
	im.create(1300,1080,false,Image.FORMAT_RGBA8)
	im.fill(Color(0,0,0,1))
	var r = hash(card.title) #generate random image based on title
	for i in range(4):
		var element = images[r%images.size()]
		im.blend_rect(element,Rect2(0,0,1300,1080),Vector2(0,0))
		r=hash(str(r).substr(0,16))
	card.image = ImageTexture.new()
	card.image.create_from_image(im);
	card.imageloaded = false

#random integer in [1, +inf)
#p(1)= .3
#p(2)= .2
#p(3)=.12
#p(4) =.08
static func r():
	return ceil(randomPositiveFloat())

static func randomPositiveFloat():
	var u  = randf()
	return 2*tan(u*PI*.5)

