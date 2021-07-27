extends Executable
var difficulty: int
var health: int
var status = {}
var title:String
var strength = 0
const basetilespeed = 11
onready var tilespeed = basetilespeed/(.001+global.animationspeed)
var speed =0
var spawnableterrains = {}
var healthBarTemplate = preload("res://HealthBar.tscn")
var healthChangeTemplate = preload("res://Units/healthChange.tscn")
var healthBar
var block = 0
var armor = 0
var maxHealth
var damagetypes= []
var tile
var image
var sight = 40
var attackrange = 1
var trap = false 
var facingtype = ["flip"]
var _imagescale
var lore
var debug
var mouseon
var head
var components=[]
var componentnames=[]
var links=[]
var linkagenames = []
var intents=[]
var skipturn
var movementPolicy="Spring"
signal animateHealthChange
const buffintents = ["gainMaxHealth","gainStrength","addStatus","setStatus","addStatus:friendly","addStatus:-friendly","setStatus:friendly","setStatus:-friendly"]

func _ready() -> void:
	global.connect("animspeedchanged",self,"on_animation_speed_changed")

func on_animation_speed_changed(animspeed):
	tilespeed = basetilespeed / (.001+animspeed)
func onSummon(head, silent= false)->void:
	self.head = head
	if head == self:
		addHealthBar()
		if not silent:
			maxHealth  = health
		if status.has("lifelink") and not silent:
			var sumMaxHealth = self.maxHealth
			var sumHealth = self.health
			for unit in get_parent().units:
				if unit!=null:
					if unit.title == self.title:
						sumMaxHealth +=unit.maxHealth
						sumHealth += unit.health
						break
			print(sumHealth, "/",sumMaxHealth)
			self.health = sumHealth
			self.updateDisplay()
			for unit in get_parent().units:
				if unit == null:
					continue
				if unit.title == self.title:
					unit.maxHealth = sumMaxHealth
					unit.health = sumHealth
					unit.updateDisplay()
	else:
		intents = []
		$Intent.updateDisplay([],get_parent().get_node("UnitLibrary").intenticons)
	if self.image!=null:
		var  imagesize =1000.0
		if status.has("boss"):
			imagesize=1400.0
		_imagescale = imagesize/max(image.get_width(), image.get_height())
		$Resizer/Image.texture = image
		$Resizer/Image.scale = Vector2(_imagescale,_imagescale)
	else:
		_imagescale = 1
		playAnimation("idle")
	if self.head == self and not silent:
		var res = self.Triggered("onSummon",[])
		if res is GDScriptFunctionState:
			res= yield(res,"completed")
		self.addStatus("stunned",1)
		if componentnames.size() > 0:
			components = []
			components.resize(componentnames.size())
			components[0] = self
		else:
			components = [self]
	if status.has("neutral"):
		$AnimationPlayer.playback_speed = .1
	else:
		$AnimationPlayer.playback_speed =rand_range(.5,1)
func _process(delta: float) -> void:
	if tile != null and (self.position - tile.position).length_squared()>100:
		self.position  = self.position.linear_interpolate(tile.position, min(1, tilespeed*delta))
	self.z_index = (500+position.y)/10;
	if mouseon:
		self.z_index+=50
	if self.trap:
		self.z_index -= 10


func addHealthBar():
	healthBar  = healthBarTemplate.instance()
	healthBar.scale = Vector2(.6,.6);
	healthBar.position = Vector2(0,190);
	add_child(healthBar)
	updateDisplay()
	
func hasProperty(prop:String):
	#Multi property things. e.g. -player&friendly
	if prop.find("&")!=-1:
		var props = prop.split("&")
		#print(str(props))
		for thing in props:
			if not self.hasProperty(thing):
				return false
		return true
		
	var negate = false
	var ret
	if prop == "-friendly" and status.has("neutral"):
		return false
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
	var armorlost = 0
	if attacker!=null:
		controller.animationController.Damage(types, attacker, self)
	if amount is GDScriptFunctionState:
		yield(amount, "completed")
	if self.trap:
		return [0]
	if self.health <=0:
		return [0]
	if status.has("corruption") and status.corruption is int:
			if attacker!=null:
				amount+=int(status.get("corruption")/3)
	if "backstab" in types and attacker!=null and attacker.status.has("stealth"):
		var stealth = attacker.status.get("stealth")
		if stealth !=null and stealth is int:
			amount*=3
	if self.interrupts.has("damaged"):
		self.vars["$DamageAmount"] = amount
		self.Interrupts("damaged", [amount,types, attacker])
		amount = self.vars["$DamageAmount"]
		if amount == 0:
			return [0]
	if "storm" in types:
		if randf()<=.05:
			amount*=2
			changeHealth("CRIT")
	if amount >=20 and amount < armor+health+block:
		say(Utility.choice(["Owww!","Ouch!", "Oof!"]))
	#put out fire
	if ("water" in types or "ice" in types) and status.has("flaming"):
		addStatus("flaming",-1)
	if "ice" in types:
		addStatus("frost",1)
	if "shadow" in types:
		addStatus("corruption",1)
	if "light" in types:
		addStatus("dazzled",1)
	#thorns
	if (status.has("thorns") and status.thorns is int and attacker !=null):
		attacker.takeDamage(status.thorns, ["thorns"],null)
	if "crush" in types and armor >0:
		armor-=1
		armorlost+=1
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
			
	if self == controller.Player and attacker != null:
		amount = controller.cardController.Reaction(amount,attacker)
		if amount is GDScriptFunctionState:
			amount = yield(amount,"completed")	
	if "stab" in types and block > 0:
		amount+=1
	
	if amount > 0 and not "piercing" in types:
		if block >amount:
			block -=floor(amount)
			amount = 0
		elif block > 0:
			amount -= block
			block = 0
		if armor > 0 and amount > 0:
			amount =max(amount -  armor, 0)
			armor -=1
			armorlost+=1
			if status.has("hardenedcarapace"):
				var res = controller.Action("addBlock", [self, 2*armorlost])
				if res is GDScriptFunctionState:
					yield(res, "completed")
			if attacker!=null and attacker.status.has("armorsteal"):
				var res = controller.Action("addArmor", [attacker, armorlost])
	if amount < 0:
		amount = 0	
	#effects on unblocked damage
	if amount > 0:
		if "fire" in types and attacker!=null:
			addStatus("flaming",1)
		if "slash" in types and block == 0 and armor == 0:
			addStatus("bleed",1)
	var default = true
	for atype in types:
		if $Audio.playsound(atype):
			default = false
			break	
	if default:
		$Audio.playsound("defaultAttack")
	if self == controller.Player:
		
		var res = controller.cardController.Action("unheal", [floor(amount)])
		if res is GDScriptFunctionState:
			yield(res, "completed")
	else:
		changeHealth(-1*floor(amount))
	if status.has("lifelink"):
		for unit in get_parent().units:
			if unit != null and unit.title == self.title:
				unit.health = self.health
				unit.updateDisplay()
	
	var res = self.Triggered("damaged",[amount,types,attacker])
	if res is GDScriptFunctionState:
		yield(res, "completed")
	if health <= 0:
		res = get_parent().cardController.triggerAll("death",[self,types,attacker])
		if res is GDScriptFunctionState:
			res= yield(res,"completed")
		if status.has("lifelink"):
			for unit in get_parent().units:
				if unit!=null:
					if unit.title == self.title and unit != self:
						unit.die(null)
		die(attacker)
		return [amount,"kill"]
	else:
		updateDisplay()
	res = get_parent().map.cardController.triggerAll("damageDealt",[self,amount,types,attacker])
	if res is GDScriptFunctionState:
		res= yield(res,"completed")
	return [amount]
func startOfTurn():
	if status.has("flaming"):
		takeDamage(3,["fire"],null)
	if not status.has("stoneskin"):
		block = 0;
	if status.has("fuse"):
		addStatus("explosive",1)
	if status.has("bleed"):
		changeHealth( -1*status.get("bleed"))
		if self.health <=0:
			die(null)
	if status.has("stunned"):
		skipturn = true
	else:
		skipturn = false
	if self == controller.Player:
		statusTickDown()
	var res = self.Triggered("startofturn",[]);
	if res is GDScriptFunctionState:
		res= yield(res,"completed")
func endOfTurn():
	var res = self.Triggered("endofturn",[]);
	if res is GDScriptFunctionState:
		res= yield(res,"completed")
	if self.trap and self.tile.occupants.size() != 0:
		res = self.Triggered("trap",[tile.occupants[0]])
		if res is GDScriptFunctionState:
			res= yield(res,"completed")
	if self != controller.Player:
		statusTickDown()
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
	#self.Triggered("onUpdate",[])
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
	if  getStrength() != 0:
		healthBar.get_node("Attack").visible = true
	else:
		healthBar.get_node("Attack").visible = false
	healthBar.get_node("Statuses").updateDisplay(status, get_parent().get_node("UnitLibrary").icons)
	if tile.neighs.size()==0 or controller.Player == null or self.health <= 0:
		intents=[]
		$Intent.updateDisplay([],get_parent().get_node("UnitLibrary").intenticons)
	else:
		intents=getIntents()
		$Intent.updateDisplay(intents, get_parent().get_node("UnitLibrary").intenticons)
	$HoverText.updateDisplay(self,get_parent().get_node("UnitLibrary"))
func die(attacker):
	print(self.title + " dying")
	if head !=self:
		head.die(attacker)
	if self == controller.Player:
			print("Intended loss")
			controller.Lose(attacker)
			return
	if self == controller.theVoid:
			controller.Win()
	if status.has("boss"):
		var res = get_parent().cardController.Action("create",["Boss Loot","Hand"])
		if res is GDScriptFunctionState:
			yield(res, "completed")
	if difficulty > 12:
		var res =get_parent().cardController.Action("create",["Rare Loot","Hand"])
		if res is GDScriptFunctionState:
			yield(res, "completed")
	elif difficulty > 7:
		var res =get_parent().cardController.Action("create",["Uncommon Loot","Hand"])
		if res is GDScriptFunctionState:
			yield(res, "completed")
	elif not status.has("lootless") and not status.has("friendly"):
		var res =get_parent().cardController.Action("create",["Common Loot","Hand"])
		if res is GDScriptFunctionState:
			yield(res, "completed")
	if status.has("supplying") and attacker != null:
		controller.gainStrength(attacker,self.strength)
	if status.has("nourishing") and attacker != null:
		controller.gainMaxHealth(attacker,self.maxHealth)
	if status.has("explosive"):
		#damage all adjacent enemies
		for node in get_parent().map.selectAll(self.tile,1,"exists",["any"]):
			if node.occupants.size()>0 and node.occupants[0] != self:
				node.occupants[0].takeDamage(status.explosive,["explosive"],self)

	
	self.visible = false
	tile.occupants.erase(self)
	if get_parent().units.find(self)==-1:
		
		print(self.title + " failed to die well")
	get_parent().units.erase(self)
	var res = self.Triggered("onDeath",[attacker])
	if res is GDScriptFunctionState:
		res= yield(res,"completed")
	res = playAnimation("die")
	for component in components:
		if component != null and component!=self:
			component.playAnimation("die")
			
#	for link in links:
#		link.queue_free()
	if res is GDScriptFunctionState:
		yield(res, "completed")
	
		_eraseSelf()
	else:
		yield(get_tree().create_timer(1),"timeout")
		_eraseSelf()
func _eraseSelf():
	print("Erasing")
	for component in components:
		if component != null and component!=self:
			component.tile.occupants.erase(component)
			print("Removing component" + component.title)
			component.queue_free()
	for link in links:
		if link != null:
			link.queue_free()
	queue_free()

func addStatus(stat, val):
	if self.head != self:
		return head.addStatus(stat,val)
	if stat == "health":
		var res = controller.Action("heal",[self, val])
		if res is GDScriptFunctionState:
			yield(res, "completed")
		return res
	elif stat == "maxHealth":
		var res = controller.Action("gainMaxHealth", [self, val])
		if res is GDScriptFunctionState:
			yield(res, "completed")
		return true
	elif stat == "strength":
		var res = controller.Action("gainStrength",[self, val])
		if res is GDScriptFunctionState:
			yield(res, "completed")
		return res
	if val is int and val ==0:
		return false
	if not stat in status or val is bool:
		status[stat] = val
	elif val is int and status[stat] is int:
		status[stat] = status[stat] + val
		if status[stat] ==0:
			status.erase(stat)
func setStatus(stat, val):
	if self.head != self:
		return head.addStatus(stat,val)
	if val is int and val ==0 or val is bool and val == false:
		status.erase(stat)
	else:
		status[stat] = val
func getStatus(stat)->int:
	if self.head != self:
		return head.getStatus(stat)
	if stat in ["block","strength","armor","maxHealth","health","speed"]:
		var val = self.get(stat)
		if val==null:
			return 0
		return val
	var val = status.get(stat)
	if val==null or val is bool and val == false:
		return 0
	if val is bool and  val == true:
		return 1
	return val
	
func loadUnitFromString(string):
	$Resizer/AnimatedSprite.visible = false
	var lines = string.split(";")
	for line in lines:
		if line == "" or line == " ":
			continue
		var parsed = Utility.parseCardCode(line)
		#print(parsed)
		if parsed[0] =="trigger":
			var trigger = parsed[1]
			Utility.addtoDict(triggers,trigger[0],  trigger.slice(1,trigger.size()-1))
		elif parsed[0]=="interrupt":
			var trigger = parsed[1]
			Utility.addtoDict(interrupts,trigger[0],  trigger.slice(1,trigger.size()-1))
		elif parsed[0] == "image":
			self.image= load(parsed[1][0])
		elif parsed[0] == "damagetypes":
			damagetypes =  parsed[1]
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
			$Resizer/Image.visible = false
			$Resizer/AnimatedSprite.visible = true
		elif parsed[0] == "facing":
			self.facingtype = parsed[1]
		elif parsed[0] == "lore":
			self.lore =  Utility.join(" ",parsed[1]).replace("\\n","\n")
		elif parsed[0] == "components":
			self.componentnames = parsed[1]
		elif parsed[0] == "linkage":
			linkagenames.append(parsed[1])
		elif parsed[0] == "movementPolicy":
			movementPolicy = parsed[1][0]
		elif parsed[0] =="event":
			vars["eventCount"] = parsed[1][0]
			vars["lastTurnSpawned"] = 0
func getIntents():
	if not triggers.has("turn"):
		return []
	var oldvars = vars.duplicate(true)
	controller.startTest()
	var res = self. Triggered("turn",[])
	if res is GDScriptFunctionState:
		res= yield(res,"completed")
	var hits = controller.endTest()
	var intents = []
	for hit in hits:
		if hit in buffintents:
			if hit.split(":").size()>1 :
				if self.hasProperty(hit.split(":")[1]):
					intents.append("Buff")
				else:
					intents.append("Debuff")
			else:
				intents.append("Buff")
		elif hit in ["Attack", "Summon", "Move","addArmor","addBlock","moveUnits"]:
			intents.append(hit)
		elif hit == "move":
			intents.append("Move")
		elif hit in ["create","createByModifier"]:
			intents.append("MakeCard")
			
	vars = oldvars
	return intents
	
func deepcopy(other):
	var properties = self.get_property_list()
	for prop in properties:
		var name = prop.name;
		if name in ["transform","position","rotation","rotation_degrees","scale"]:
			continue
		var val = self.get(name);
		if val is Array or val is Dictionary:
			other.set(name,val.duplicate(true))
		elif val == null or not val is Object:
			other.set(name, val);
		else:
			pass
	if $Resizer/Image.visible:
		other.image = self.image
		other.get_node("Resizer/AnimatedSprite").visible = false
	else: 
		other.get_node("Resizer/Image").visible = false
		other.get_node("Resizer/AnimatedSprite").visible = true
	other.get_node("Resizer/AnimatedSprite").frames = $Resizer/AnimatedSprite.frames
	other.controller = self.controller
	other.updateDisplay()
	return other	
func hasName(string)->bool:
	return self.title.find(string)!=-1
func getStrength(amount = 0):
	var ret = amount+  self.strength
	if status.has("frost"):
		ret -= status.frost
	if status.has("flaming"):
		ret += 2*status.flaming
	if status.has("rage"):
		ret+=status.rage
	if status.has("dazzled"):
		ret*= .66
	return int(ret)
func isUnit()->bool:
	return true
func changeHealth(amount)-> void:
	if not amount is String:
		if status.has("sting") and amount > 0:
			amount=0
		health += amount
	var num = healthChangeTemplate.instance()
	
	self.add_child(num)
	num.get_node("CanvasLayer/Control").rect_scale =  Vector2(.4,.4)
	num.get_node("CanvasLayer").offset  = self.get_global_transform().get_origin()+Vector2(rand_range(-50,50),rand_range(-50,50)) + get_node("/root/Scene/Center/MapLayer").offset
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
	debug = $Resizer/AnimatedSprite
	if $Resizer/AnimatedSprite.frames.has_animation(action):
		$Resizer/AnimatedSprite.play(action)
		if not $Resizer/AnimatedSprite.frames.get_animation_loop(action):
			yield($Resizer/AnimatedSprite,"animation_finished")
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
	var frames = $Resizer/AnimatedSprite.frames
	frames.add_animation(action)
	for frame in sheetframes:
		frames.add_frame(action,sheet[frame])
	frames.set_animation_speed(action, animspeed)
	if action =="idle":
		frames.set_animation_loop(action,true)
	else:
		frames.set_animation_loop(action,false)
	$Resizer/AnimatedSprite.frames = frames
	debug = $Resizer/AnimatedSprite
func facing(angle):
	if facingtype[0] == "none":
		return
	if facingtype[0] == "flip":
		if angle < PI/2 or angle > 3*PI/2 :
			$Resizer/Image.scale = Vector2(-1*_imagescale,_imagescale)
			$Resizer/AnimatedSprite.scale = Vector2(-1*_imagescale,_imagescale)
		else:
			$Resizer/Image.scale = Vector2(_imagescale,_imagescale)
			$Resizer/AnimatedSprite.scale = Vector2(_imagescale,_imagescale)
	elif facingtype[0] == "topdown":
		$Resizer/Image.rotation = angle + PI/2
		$Resizer/AnimatedSprite.rotation = angle+ PI/2


func _on_HoverRect_mouse_entered() -> void:
	if head!=self and head!=null:
		return head._on_HoverRect_mouse_entered()
	mouseon = true
	yield(get_tree().create_timer(.2),"timeout")
	if mouseon:
		$HoverText/Fader.play("Fade")
		

func _on_HoverRect_mouse_exited() -> void:
	if head!=self:
		return head._on_HoverRect_mouse_exited()
	mouseon = false
	if $HoverText.modulate.a >0 and $HoverText.modulate.a < 1:
		yield($HoverText/Fader,"animation_finished")
	if $HoverText.modulate.a == 1:
		$HoverText/Fader.play_backwards("Fade")
	
func save() -> Dictionary:
	var savecomponents = []
	for component in components:
		if component!=self:
			savecomponents.append(component.save())
	var savelinkages = []
	for link in links:
		savelinkages.append(link.save())
	var tileindex = controller.map.nodes.find(self.tile)
	return{
		"title":title,
		"vars":vars,
		"health":health,
		"maxHealth":maxHealth,
		"strength":strength,
		"status":status,
		"block":block,
		"armor":armor,
		"components":savecomponents,
		"links":savelinkages,
		"tile": tileindex
	}
func loadFromSave(save:Dictionary):
	vars = save.vars
	for key in vars:
		if vars[key] is float:
			vars[key] = int(vars[key])
	health = save.health
	maxHealth = save.maxHealth
	strength = save.strength
	status = save.status
	block = save.block
	armor = save.armor
	components = [self]
	for savecomponent in save.components:
		var component = controller.get_node("UnitLibrary").getUnitByName(savecomponent.title)
		get_parent().add_child(component)
		component.scale = get_parent().unitscale
		component.loadFromSave(savecomponent)
		component.onSummon(self,true)
		component.controller = self.controller
		components.append(component)
		
		
	links = []
	for savelink in save.links:
		var link = controller.get_node("UnitLibrary").getLinkageByName(savelink.title)
		link.head = self
		link.loadFromSave(savelink)
		links.append(link)
		get_parent().add_child(link)
	self.tile = controller.map.nodes[int(save.tile)]
	if not self.trap:
		self.tile.occupants.append(self)
	


func _on_HoverRect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		controller.map.on_MapArea_input_event(event) #pass input to map click

func say(text:String, time = 2):
	if text == "":
		$SpeechBubble.visible = false
		return
	var textbox = $SpeechBubble/Text
	var boxSize = Vector2(733,516);
	var sc = sqrt(14.0/text.length())
	boxSize /= sc
	textbox.bbcode_enabled = true
	textbox.bbcode_text = "[center]"+text+"[/center]"
	textbox.rect_scale=  Vector2(sc,sc);
	textbox.rect_size = boxSize;
	$SpeechBubble.visible = true
	if time > 0:
		yield(get_tree().create_timer(time),"timeout")
		$SpeechBubble.visible = false
