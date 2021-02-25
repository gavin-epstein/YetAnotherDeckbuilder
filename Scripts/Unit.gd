extends Executable
var difficulty: int
var health: int
var status = {}
var title:String
var strength = 0
const tilespeed  = 10
var speed
var spawnableterrains = {}
var healthBarTemplate = preload("res://HealthBar.tscn")
var healthChangeTemplate = preload("res://Units/healthChange.tscn")
var healthBar
var block = 0
var armor = 0
var maxHealth
var damagetypes= []
var tile
var nextTurn =[]
var image
var sight = 40
var attackrange = 1
var trap = false #trans rights
var facingtype = ["flip"]
var _imagescale
var lore
var debug
var mouseon
signal animateHealthChange
const buffintents = ["gainArmor","gainBlock", "gainMaxHealth","gainStrength","addStatus","setStatus"]
func _ready() -> void:
	onSummon()
func onSummon()->void:
	addHealthBar()
	maxHealth  = health
	if status.has("lifelink"):
		var sumMaxHealth = self.maxHealth
		var sumHealth = self.health
		for unit in get_parent().units:
			if unit!=null:
				if unit.title == self.title:
					sumMaxHealth +=unit.maxHealth
					sumHealth += unit.health
					break
		print(sumHealth, "/",sumMaxHealth)
		self.maxHealth = sumMaxHealth
		self.health = sumHealth
		self.updateDisplay()
		for unit in get_parent().units:
			if unit == null:
				continue
			if unit.title == self.title:
				unit.maxHealth = sumMaxHealth
				unit.health = sumHealth
				unit.updateDisplay()
	if self.image!=null:
		_imagescale = 1000.0/max(image.get_width(), image.get_height())
		$Image.texture = image
		$Image.scale = Vector2(_imagescale,_imagescale)
	else:
		_imagescale = 1
	playAnimation("idle")
	self.Triggered("onSummon",[])
	self.addStatus("New",1)
func _process(delta: float) -> void:
	if tile != null and (self.position - tile.position).length_squared()>100:
		self.position  = self.position.linear_interpolate(tile.position, min(1, tilespeed*delta))
	self.z_index = (500+position.y)/10;
	if self.trap:
		self.z_index -= 10


func addHealthBar():
	healthBar  = healthBarTemplate.instance()
	healthBar.scale = Vector2(.6,.6);
	healthBar.position = Vector2(0,190);
	add_child(healthBar)
	updateDisplay()
	
func hasProperty(prop:String):
	var negate = false
	var ret
	if prop[0] == "-":
		negate = true
		prop = prop.substr(1)
	if prop == 'any' or prop == "exists":
		ret =true
	elif prop == self.title:
		ret = true
	elif status.has(prop):
		ret = true
	elif prop.begins_with("name:"):
		if prop.substr(5) in self.title:
			ret = true
	else:
		ret = false
	if negate:
		return not ret
	else:
		return ret
func takeDamage(amount,types, attacker):
	if self.trap:
		return [0]
	if self.health <=0:
		return [0]
	
	#put out fire
	if ("water" in types or "ice" in types) and status.has("flaming"):
		addStatus("flaming",-1)
	if "ice" in types:
		addStatus("frost",1)
	#thorns
	if (status.has("thorns") and status.thorns is int and attacker !=null):
		attacker.takeDamage(status.thorns, ["thorns"],null)
	if "crush" in types and armor >0:
		armor-=1
	for atype in types:
		if status.has("immune:"+atype) or status.has("immune:any"):
			amount = 0
			break
	for atype in types:
		if status.has("resistant:"+atype) or status.has("resistant:any"):
			amount = amount/2.0
			break
	for atype in types:
		if status.has("vulnerable:"+atype)or status.has("vulnerable:any"):
			amount = amount*1.5
			
	if self == controller.Player:
		amount = controller.cardController.Reaction(amount)		
	if "stab" in types and block > 0:
		amount+=1
	
	if amount > 0:
		if armor > 0:
			amount =max(amount -  armor, 0)
			armor -=1
			if status.has("hardenedcarapace"):
				controller.Action("addBlock", [self, 2])
		if block >amount:
			block -=floor(amount)
			amount = 0
		elif block > 0:
			amount -= block
			block = 0
	#effects on unblocked damage
	if amount > 0:
		if "fire" in types and attacker!=null:
			addStatus("flaming",1)
		if "slash" in types and block == 0 and armor == 0:
			addStatus("bleed",1)
		
	changeHealth(-1*floor(amount))
	if status.has("lifelink"):
		for unit in get_parent().units:
			if unit != null and unit.title == self.title:
				unit.health = self.health
				unit.updateDisplay()
	if amount > 0:	
		self.Triggered("damaged",[amount,types,attacker])
	if health <= 0:
		
		get_parent().map.cardController.triggerAll("death",[self,types,attacker])
		if status.has("lifelink"):
			for unit in get_parent().units:
				if unit!=null:
					if unit.title == self.title and unit != self:
						unit.die(null)
		die(attacker)
		return [amount,"kill"]
	else:
		updateDisplay()
	get_parent().map.cardController.triggerAll("damageDealt",[self,amount,types,attacker])
	return [amount]
func startOfTurn():
	if status.has("flaming"):
		takeDamage(4,["fire"],null)
	block = 0;
	if status.has("fuse"):
		addStatus("explosive",1)
	if status.has("bleed"):
		changeHealth( -1*status.get("bleed"))
		if self.health <=0:
			die(null)
	statusTickDown()
	self.Triggered("startofturn",[]);
func endOfTurn():
	self.Triggered("endofturn",[]);
	if self.trap and self.tile.occupants.size() != 0:
		self.Triggered("trap",[tile.occupants[0]])
func statusTickDown():
	if status.has("fuse") and status.fuse ==1:
		setStatus("fuse",0)
		die("fuse")
	if status.has("expire") and status.expire == 1:
		setStatus("expire",0)
		die("expire")
	for key in status:
		if status[key] is int:
			status[key] = status[key]-1
			if status[key] <= 0:
				status.erase(key)
		
func updateDisplay():
	if tile == null:
		return false
	if healthBar == null:
		yield(self,"ready")
	healthBar.get_node("Heart/Number").bbcode_text = "[center]"+str(health)+"[/center]"
	healthBar.get_node("Block/Number").bbcode_text = "[center]"+str(block)+"[/center]"
	healthBar.get_node("Armor/Number").bbcode_text = "[center]"+str(armor)+"[/center]"
	healthBar.get_node("Attack/Number").bbcode_text = "[center]"+str(getStrength())+"[/center]"
	if trap:
		healthBar.get_node("Heart").visible = false
	if block > 0:
		healthBar.get_node("Block").visible = true
	else:
		healthBar.get_node("Block").visible = false
	if armor > 0:
		healthBar.get_node("Armor").visible = true
	else:
		healthBar.get_node("Armor").visible = false
	if  getStrength() > 0:
		healthBar.get_node("Attack").visible = true
	else:
		healthBar.get_node("Attack").visible = false
	healthBar.get_node("Statuses").updateDisplay(status, get_parent().get_node("UnitLibrary").icons)
	if tile.neighs.size()==0 or controller.Player == null or self.health <= 0:
		$Intent.updateDisplay([],get_parent().get_node("UnitLibrary").intenticons)
	else:
		$Intent.updateDisplay(getIntents(), get_parent().get_node("UnitLibrary").intenticons)
	$HoverText.updateDisplay(self,get_parent().get_node("UnitLibrary"))
func die(attacker):
	if difficulty > 10:
		get_parent().cardController.Action("create",["Rare Loot","Discard"])
	elif difficulty > 5:
		get_parent().cardController.Action("create",["Uncommon Loot","Discard"])
	elif self.difficulty > 1:
		get_parent().cardController.Action("create",["Common Loot","Discard"])
	if status.has("supplying") and attacker != null:
		controller.gainStrength(attacker,self.strength)
	if status.has("nourishing") and attacker != null:
		controller.gainMaxHealth(attacker,self.maxHealth)
	if status.has("explosive"):
		#damage all adjacent enemies
		for node in get_parent().map.selectAll(self.tile,1,"exists",["any"]):
			if node.occupants.size()>0 and node.occupants[0] != self:
				node.occupants[0].takeDamage(status.explosive,("explosive"),self)
	
	self.visible = false
	tile.occupants.erase(self)
	if get_parent().units.find(self)==-1:
		if self == controller.Player:
			controller.endGame()
		print(self.title + " failed to die well")
		#assert(false, "failure to die properly" )
	get_parent().units.erase(self)
	self.Triggered("onDeath",[attacker])
	var res = playAnimation("die")
	if res is GDScriptFunctionState:
		yield(res, "completed")
		queue_free()
	else:
		yield(get_tree().create_timer(1),"timeout")
		queue_free()

func addStatus(stat, val):
	if stat == "health":
		controller.Action("heal",[self, val])
		return true
	elif stat == "maxHealth":
		controller.Action("gainMaxHealth", [self, val])
		return true
	elif stat == "strength":
		controller.Action("gainStrength",[self, val])
		return true
	if val is int and val ==0:
		return false
	if not stat in status or val is bool:
		status[stat] = val
	elif val is int and status[stat] is int:
		status[stat] = status[stat] + val
		if status[stat] ==0:
			status.erase(stat)
func setStatus(stat, val):
	if val is int and val ==0 or val is bool and val == false:
		status.erase(stat)
	else:
		status[stat] = val
func loadUnitFromString(string):
	$AnimatedSprite.visible = false
	var lines = string.split(";")
	for line in lines:
		if line == "" or line == " ":
			continue
		var parsed = Utility.parseCardCode(line)
		#print(parsed)
		if parsed[0] =="trigger":
			var trigger = parsed[1]
			Utility.addtoDict(triggers,trigger[0],  trigger.slice(1,trigger.size()-1))
		elif parsed[0] == "damagetypes":
			damagetypes =  parsed[1]
		elif parsed[0] == "image":
			self.image = load(parsed[1][0])
		elif parsed[0] == "title" or parsed[0] =="name":
			self.title = Utility.join(" ",parsed[1])
		elif parsed[0][0] =="$":
			vars[parsed[0]] = parsed[2]
		elif parsed[0] == "difficulty":
			self.difficulty = parsed[1][0]
		elif parsed[0] == "health":
			self.health = parsed[1][0]
		elif parsed[0] == "status":
			status[parsed[1][0]] = processArgs(parsed[1][1],[])
		elif parsed[0] == "strength":
			self.strength = parsed[1][0]
		elif parsed[0] == "speed":
			self.speed = parsed[1][0]
		elif parsed[0] == "spawnable":
			for terrain in parsed[1]:
				spawnableterrains[terrain] = true
		elif parsed[0] == "sight":
			sight = parsed[1][0]
		elif parsed[0] == "range":
			attackrange = parsed[1][0]
		elif parsed[0] == "trap":
			trap = true
		elif parsed[0] == "animation":
			callv("loadAnimation", parsed[1])
			$Image.visible = false
			$AnimatedSprite.visible = true
		elif parsed[0] == "facing":
			self.facingtype = parsed[1]
		elif parsed[0] == "lore":
			self.lore =  Utility.join(" ",parsed[1]).replace("\\n","\n")
func getIntents():
	if not triggers.has("turn"):
		return []
	var oldvars = vars.duplicate(true)
	controller.startTest()
	self. Triggered("turn",[])
	var hits = controller.endTest()
	var intents = []
	for hit in hits:
		if hit in buffintents:
			intents.append("Buff")
		elif hit == "Attack" or hit == "Summon" or hit == "Move":
			intents.append(hit)
		elif hit == "move":
			intents.append("Move")
		elif hit == "MoveAndAttack":
			intents.append("Move")
			intents.append("Attack")
	vars = oldvars
	return intents
	
func deepcopy(other):
	var properties = self.get_property_list()
	for prop in properties:
		var name = prop.name;
		var val = self.get(name);
		if val is Array or val is Dictionary:
			other.set(name,val.duplicate(true))
		elif val == null or not val is Object:
			other.set(name, val);
		else:
			pass
	if $Image.visible:
		other.image = self.image
		other.get_node("AnimatedSprite").visible = false
	else: 
		other.get_node("Image").visible = false
		other.get_node("AnimatedSprite").visible = true
	other.get_node("AnimatedSprite").frames = $AnimatedSprite.frames
	other.controller = self.controller
	other.updateDisplay()
	return other	
func hasName(string)->bool:
	return self.title.find(string)!=-1
func getStrength():
	var ret = self.strength
	if status.has("frost"):
		ret -= status.frost
	if status.has("flaming"):
		ret += status.flaming
	if status.has("weak"):
		ret*= .5
	return ret
func isUnit()->bool:
	return true
func changeHealth(amount)-> void:
	health += amount
	var num = healthChangeTemplate.instance()
	
	self.add_child(num)
	num.get_node("CanvasLayer/Control").rect_scale =  Vector2(.4,.4)
	num.get_node("CanvasLayer").offset  = self.get_global_transform().get_origin()+Vector2(rand_range(-50,50),rand_range(-50,50))
	num.number  =amount
	emit_signal("animateHealthChange")

#Params
#action - animation name: "idle", "attack","defend","move"
#sheetframes, frames in order
#size - size of one frame
#count - dimentsions in frames of image
#e.g.
# [0] [1] [2]
# [3] [4] [5]
#size (1,1)
#count (2,3)
func playAnimation(action):
	debug = $AnimatedSprite
	if $AnimatedSprite.frames.has_animation(action):
		$AnimatedSprite.play(action)
	if not $AnimatedSprite.frames.get_animation_loop(action):
		yield($AnimatedSprite,"animation_finished")
		playAnimation("idle")
		
func loadAnimation(action,file, sheetframes,size,count,animspeed=1,loop=false):
	if not size is Vector2:
		size = Vector2(size[0],size[1])
	if not count is Vector2:
		count = Vector2(count[0],count[1])
	var tex:Texture = load(file)
	var sheet = []
	for y in range(count.y):
		for x in range(count.x):
			var f = AtlasTexture.new()
			f.atlas = tex
			f.region = Rect2(size.x*x, size.y*y, size.x, size.y)
			sheet.append(f)
	var frames = $AnimatedSprite.frames
	frames.add_animation(action)
	for frame in sheetframes:
		frames.add_frame(action,sheet[frame])
	frames.set_animation_speed(action, animspeed)
	if action =="idle":
		frames.set_animation_loop(action,true)
	else:
		frames.set_animation_loop(action,false)
	$AnimatedSprite.frames = frames
	debug = $AnimatedSprite
func facing(angle):
	if facingtype[0] == "none":
		return
	if facingtype[0] == "flip":
		if angle < PI/2 or angle > 3*PI/2 :
			$Image.scale = Vector2(-1*_imagescale,_imagescale)
			$AnimatedSprite.scale = Vector2(-1*_imagescale,_imagescale)
		else:
			$Image.scale = Vector2(_imagescale,_imagescale)
			$AnimatedSprite.scale = Vector2(_imagescale,_imagescale)
	elif facingtype[0] == "topdown":
		$Image.rotation = angle + PI/2
		$AnimatedSprite.rotation = angle+ PI/2


func _on_HoverRect_mouse_entered() -> void:
	mouseon = true
	yield(get_tree().create_timer(.2),"timeout")
	if mouseon:
		$HoverText/Fader.play("Fade")
		

func _on_HoverRect_mouse_exited() -> void:
	mouseon = false
	if $HoverText.modulate.a >0 and $HoverText.modulate.a < 1:
		yield($HoverText/Fader,"animation_finished")
	if $HoverText.modulate.a == 1:
		$HoverText/Fader.play_backwards("Fade")
	
