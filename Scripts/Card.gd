extends "res://Scripts/Executable.gd"
class_name Card

#constants
const zoomoffset = Vector2(0,-100)
const speed  = 10
#vars
var types = {}
var text=""
var image
var title
var modifiers = {}
var removetype
var target_scale
var target_position
var highlighted = false
var rarity = 0
var debug
var mouseon
var tooltips=[]
var iconsdone = false
var targetvis=true
var base_z = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.image!=null:
		$Resizer/CardArt.texture = image
	
func _process(delta: float) -> void: 
	#normal movement 

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
				z_index = base_z+5
				$AnimationPlayer.play("Grow")
			yield($AnimationPlayer,"animation_finished")
	else:
		if $Resizer.scale.x ==1.5:
			$AnimationPlayer.play_backwards("Grow")
		z_index = base_z
		


func hasType(type)->bool:
	if type == "any":
		return true
	if types.has(type):
		return true
	return false
	
func hasName(string)->bool:
	return self.title.to_lower().find(string.to_lower())!=-1
	
func hasModifier(string) -> bool:
	if string == "any":
		return true
	if modifiers.has(string):
		return true
	return false

func loadCardFromString(string):
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
		elif parsed[0] == "image":
			self.image = load(parsed[1][0])
		elif parsed[0] == "title":
			self.title = Utility.join(" ",parsed[1])
		elif parsed[0] == "rarity":
			self.rarity = int(parsed[1][0])
		elif parsed[0][0] =="$":
			vars[parsed[0]] = parsed[2]
		
	#self.updateDisplay()
	self.generateTooltips()
func updateDisplay():
	get_node("Resizer/CardFrame/Cost").bbcode_text= "[center]" + str(vars["$Cost"]) + "[/center]";
	var titlebox = get_node("Resizer/CardFrame/Title")
	titlebox.bbcode_text= "[center]" + title+ "[/center]";
	var titlescale = min(.5,6.0/title.length())
	titlebox.rect_scale = Vector2(titlescale,titlescale)
	titlebox.rect_size = Vector2(583.0/titlescale,211)
	var displaytext = text
	for key in vars:
		if vars[key] is String or vars[key] is int:
			displaytext = displaytext.replace(key, vars[key])
	get_node("Resizer/CardFrame/Text").bbcode_text = "[center]"+displaytext+ "[/center]";
	get_node("Resizer/CardFrame/Timer").bbcode_text= "[center]" + str(vars["$removecount"]) + "[/center]";
	get_node("Resizer/CardFrame/arrow").visible =false
	get_node("Resizer/CardFrame/hourglass").visible = false
	get_node("Resizer/CardFrame/Endless").visible = false
	if removetype == "never":
		vars["$removecount"] = -1
		get_node("Resizer/CardFrame/Endless").visible = true
		get_node("Resizer/CardFrame/Timer").visible = false
	elif removetype == "endofturn":
		get_node("Resizer/CardFrame/hourglass").visible = true
	else:	
		get_node("Resizer/CardFrame/arrow").visible =true
	if $Resizer.scale.x > 1.1:
		$AnimationPlayer.play_backwards("Grow")
	if not iconsdone:
		iconsdone = true
		$Resizer/TypeIcons.generate()
func deepcopy(other)-> Card:
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
			#print(val)
	
	other.image = self.image
	other.controller = self.controller
	if other.modifiers.has("void"):
		other.get_node("Resizer/FrameSprite").modulate = Color(.5,0,.5)
	elif other.modifiers.has("unique"):
		other.get_node("Resizer/FrameSprite").modulate = Color(.5,.5,1)
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
	var regex = RegEx.new()
	regex.compile('(\\s+)|([.,!?:;\"-])+')
	var words = regex.sub(self.text,"@",true)
	for _i in range(3):
		words = words.replace("@@","@")
	words = words.split("@")
	for word in words:
		var tip = controller.Library.getToolTip(word)
		if tip !=null:
			tooltips.append(word.capitalize()+": "+tip)
		
func save() -> Dictionary:
	return{
		"title":title,
		"vars":vars,
		"visible":visible
	}

func loadFromSave(save:Dictionary):
	self.vars = save.vars
	for key in vars:
		if vars[key] is float:
			vars[key] = int(vars[key])
	self.visible = save.visible
	self.updateDisplay()



func _on_ColorRect_mouse_exited() -> void:
	mouseon = false
	controller.releaseFocus(self)


func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if controller.takeFocus(self):
		controller.releaseFocus(self)
		mouseon = true
	if event.is_action_pressed("left_click") and controller.takeFocus(self):
		controller.releaseFocus(self)
		if get_parent().has_method("cardClicked"):
			get_parent().cardClicked(self)
	if event.is_action_pressed("right_click"):
		controller.get_node("CardDisplay").display(self)
		mouseon=false
	
