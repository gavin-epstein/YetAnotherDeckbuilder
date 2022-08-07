extends "res://Scripts/Executable.gd"
class_name Card

#constants
const zoomoffset = Vector2(0,-100)
const speed  = 10
#vars
var types = {}
var text=""
var image
var imageloaded = false
var title
var modifiers = {}
var deleted = false
var removetype
var target_scale
var target_position
var highlighted = false
var rarity = 0
var debug
var mouseon=false
var tooltips=null
var iconsdone = false
var targetvis=true
var base_z = 0


	
func _process(delta: float) -> void: 
	#normal movement 
	if self.visible==false:
		return
	if target_position != null:
		self.position = self.position.linear_interpolate(target_position, min(1,speed*delta))
		if (position-target_position).length_squared() < 9:
			self.position = target_position
			if target_scale != null:
				scale = target_scale
			self.visible = targetvis
	if target_scale != null:
		self.scale = self.scale.linear_interpolate(target_scale,speed*delta)

	
	#zoom on mouseover
	if mouseon:
			if $Resizer.scale.x ==1:
				self.z_index = base_z+5
				$AnimationPlayer.play("Grow")
			yield($AnimationPlayer,"animation_finished")
	else:
		if $Resizer.scale.x ==1.5:
			$AnimationPlayer.play_backwards("Grow")
		self.z_index = base_z
		
		


func hasType(type)->bool:
	if type == "any":
		return true
	if types.has(type):
		return true
	return false
	
func hasName(string, exact=false)->bool:
	#print("checking if " + title +" contains " +string+ " "+str(exact))
	if exact:
		print(self.title.to_lower() == string.to_lower())
		return self.title.to_lower() == string.to_lower()
	return self.title.to_lower().find(string.to_lower())!=-1
	
func hasModifier(string) -> bool:
	if not string is String:
		return false
	if string == "any":
		return true
	if modifiers.has(string):
		return true
	return false

func loadCardFromString(string):
	var lines = string.split(";")
	for line in lines:
		if line.strip_edges() == "" :
			continue
		var parsed = Utility.parseCardCode(line)
#		if(self.title == "Rekindle"):

#			print(parsed)
		if parsed[0] =="trigger":
			var trigger = parsed[1]
			Utility.addtoDict(triggers,trigger[0],  trigger.slice(1,trigger.size()-1))
		elif parsed[0]=="interrupt":
			var trigger = parsed[1]
			Utility.addtoDict(interrupts,trigger[0],  trigger.slice(1,trigger.size()-1))
		elif parsed[0] == "removetrigger":
			var removetrigger = parsed[1]
			Utility.addtoDict(triggers ,removetrigger[0], ["if", [removetrigger[1],["decrementRemoveCount"]]])
			vars["$removecount"] =removetrigger[2]
			vars["$defaultremovecount"] = removetrigger[2]
			removetype = removetrigger[0]
		elif parsed[0] == "types":
			for type in parsed[1]:
				types[type] = true
		elif parsed[0] == "modifiers":
			for mod in parsed[1]:
				modifiers[mod] = true
		elif parsed[0] == "cost":
			var cost = parsed[1][0]
			self.vars["$Cost"] = cost
			self.vars["$BaseCost"] = cost
		elif parsed[0] =="text":
			self.text =  Utility.join(" ",parsed[1]).replace("\\n","\n")
			self.text = self.text.replace(" $Damage "," (getDamage($Damage)) ")
		elif parsed[0] == "image":
			self.image = parsed[1][0]
		elif parsed[0] == "title":
			self.title = Utility.join(" ",parsed[1])
		elif parsed[0] == "rarity":
			self.rarity = int(parsed[1][0])
		elif parsed[0][0] =="$":
			vars[parsed[0]] = parsed[2]
	if hasModifier("permafrost"):
		modifiers.frozen = true
	#self.updateDisplay()
	
func updateDisplay():
	if self.image!=null and ! imageloaded :
		if image is String:
			$Resizer/CardArt.texture = load(image)
		elif image is ImageTexture:
			$Resizer/CardArt.texture = image
		imageloaded = true
	if tooltips ==null and controller.enemyController!=null:
		self.generateTooltips()
	
	if get_parent()!=null and get_parent().get("cards")!=null:
		base_z = get_parent().base_z +1 + get_parent().cards.find(self)
		
	if mouseon:
		z_index = base_z+5
	else:
		z_index  = base_z
	if self.modifiers.has("frozen"):
		$Resizer/FrozenFrame.visible = true
	else:
		$Resizer/FrozenFrame.visible = false
	if self.modifiers.has("temporary"):
		$Resizer/TemporaryFrame.visible = true
		$Resizer/FrameSprite.visible = false
	else:
		$Resizer/TemporaryFrame.visible = false
		$Resizer/FrameSprite.visible = true
	get_node("Resizer/CardFrame/Cost").bbcode_text= "[center]" + str(vars["$Cost"]) + "[/center]";
	var titlebox = get_node("Resizer/CardFrame/Title")
	titlebox.bbcode_text= "[center]" + title +  "[/center]";
	var titlescale = min(.5,6.0/title.length())
	titlebox.rect_scale = Vector2(titlescale,titlescale)
	titlebox.rect_size = Vector2(583.0/titlescale,211)
	var displaytext = processText(text)
	var lines = ceil(displaytext.length() / 23.0)
	var sc = 1
	if lines > 5:
		sc= .7
	get_node("Resizer/CardFrame/Text").rect_scale=Vector2(.4,.4)*sc
	get_node("Resizer/CardFrame/Text").rect_size= Vector2(1644, 894)/sc
	get_node("Resizer/CardFrame/Text").bbcode_text = "[center]"+displaytext+ "[/center]";
	get_node("Resizer/CardFrame/Timer").bbcode_text= "[center]" + str(vars["$removecount"]) + "[/center]";
	get_node("Resizer/CardFrame/arrow").visible =false
	get_node("Resizer/CardFrame/hourglass").visible = false
	get_node("Resizer/CardFrame/Endless").visible = false
	get_node("Resizer/CardFrame/Tapicon").visible = false
	if removetype == "never":
		vars["$removecount"] = -1
		get_node("Resizer/CardFrame/Endless").visible = true
		get_node("Resizer/CardFrame/Timer").visible = false
	elif removetype == "endofturn":
		get_node("Resizer/CardFrame/hourglass").visible = true
	elif removetype =="tap":
		get_node("Resizer/CardFrame/Tapicon").visible = true
	else:	
		get_node("Resizer/CardFrame/arrow").visible =true
	if $Resizer.scale.x > 1.1:
		$AnimationPlayer.play_backwards("Grow")
	if not iconsdone:
		iconsdone = true
		$Resizer/TypeIcons.generate()
func deepcopy(other)-> Card:
	var properties = self.get_property_list()
	var node2DProps = Node2D.new().get_property_list()
	for i in range(len(node2DProps)):
		node2DProps[i] = node2DProps[i].name
	for prop in properties:
		var name = prop.name;
		if name in node2DProps :
			continue
		var val = self.get(name);
		
		if val is Array or val is Dictionary:
			other.set(name,val.duplicate(true))
		elif val == null or not val is Object:
			other.set(name, val);
		else:
			pass
			#print(val)
	
	other.image = self.image
	other.imageloaded=false
	other.controller = self.controller
	if other.modifiers.has("void"):
		other.get_node("Resizer/FrameSprite").modulate = Color(.7,.7,.7)
	elif other.modifiers.has("unique"):
		other.get_node("Resizer/FrameSprite").modulate = Color(.7,.7,1)
	other.updateDisplay()
	return other
		
func moveTo(pos:Vector2, size = null, vis = true):
	if target_position == null:
		self.position = pos
		self.target_position = pos
		if size !=null:
			self.scale = size
	else:
		
		self.target_scale = size
		self.target_position = pos
	targetvis = vis
	set_process(vis)
	
func highlight():
	self.highlighted = true
	$Resizer/CardHighlight.visible = true
func dehighlight():
	self.highlighted = false
	$Resizer/CardHighlight.visible = false

		

func isCard():
	return true	

func isIdentical(other):
	if self.title != other.title:
		return false
	for v in vars:
		if !(other.vars.has(v) and other.vars[v] == vars[v]):
			return false
	return true
func getTooltips():
	return tooltips
func generateTooltips():
	tooltips = []
	var words = Utility.parsewords(self.text)
	for word in words:
		var tip = controller.Library.getToolTip(word)
		if tip !=null:
			tooltips.append(word.capitalize()+": "+tip)
		else:
			tip = controller.enemyController.get_node("UnitLibrary").getToolTipByName(word)
			if tip !=null:
				tooltips.append(word.capitalize()+": "+tip)
		
func save() -> Dictionary:
	return{
		"title":title,
		"vars":vars,
		"visible":visible,
		"modifiers":modifiers,
		"triggers":triggers,
		"interrupts":interrupts,
		"types":types,
		"removetype":removetype,
		"text":text
	}

func loadFromSave(save:Dictionary):
	self.vars = save.vars
	for key in vars:
		if vars[key] is float:
			vars[key] = int(vars[key])
	self.modifiers = save.modifiers
	self.visible = save.visible
	self.triggers = save.triggers
	self.interrupts = save.interrupts
	self.types = save.types
	self.removetype = save.removetype
	self.text = save.text
	self.updateDisplay()
		
	



func _on_ColorRect_mouse_exited() -> void:
	mouseon = false
	controller.releaseFocus(self)


func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if controller.takeFocus(self):
		controller.releaseFocus(self)
		if not get_parent() is CardPile:
			mouseon = true
	if event.is_action_pressed("left_click") and controller.takeFocus(self):
		controller.releaseFocus(self)
		if get_parent().has_method("cardClicked"):
	#		print("click on " + self.title)
			get_parent().cardClicked(self)
	if event.is_action_pressed("right_click"):
		controller.get_node("CardDisplay").display(self)
		mouseon=false
func processText(text):
	
	var out =""
	#TODO custom parser that includes commas except in code
	var tokens = text.split(" ", false)
	var codeon = false
	var code = ""
	var ind = 0
	var parenstack=0
	while ind<tokens.size():
		var token = tokens[ind]
		
		if not codeon:
			#check if starts code block
			if token[0] == "(":
				codeon=true
				continue
			else:
				#if its a variable
				if token is String and token[0] =="$":
					var punct = ""
					if token[-1] in [".",","]:
						punct = token[-1]
					var v = token.rstrip(".,")
					if v in vars:
						out += str(vars[v]) + punct+" "
					
				else:
					#its a normmal string or number
					out += str(token) + " "
			ind+=1
		else:
			#currently in a code block
			code+=token
			for letter in token:
				if letter == "(":
					parenstack+=1
				elif letter== ")":
					parenstack-=1
			if parenstack == 0:
				code = Utility.parseCardCode(code)
				controller.test = true
				var res = processArgs(code[0],[])
				if res is GDScriptFunctionState:
					print("There should be no player input on card text")
					yield(res,"completed")
				controller.test = false
				out+=str(res)+" "
				code = ""
				codeon = false
			ind+=1
	return out
