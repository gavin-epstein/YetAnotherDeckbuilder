extends Node2D
class_name Card
var controller
#constants
var zoomoffset = Vector2(0,-100)
var speed  = 10
#vars
var triggers = {}
var interruptions ={}
var cost
var unmodifiedCost
var removecount
var defaultremovecount
var results:Dictionary
var types = {}
var text
var image
var title
var modifiers = {}
var removetype
var target_scale
var target_position

var rarity

var mouseoverdelay = 0
var mouseon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.image!=null:
		$Resizer/CardArt.texture = image
	
func _process(delta: float) -> void: 
	#normal movement 
	if not mouseon:
		if target_position != null:
			self.position = self.position.linear_interpolate(target_position, speed*delta)
			if (position-target_position).length_squared() < 9:
				self.position = target_position
				if target_scale != null:
					scale = target_scale
		if target_scale != null:
			self.scale = self.scale.linear_interpolate(target_scale,speed*delta)
#	else:
#		mouseoverdelay +=delta
#		if target_position != null:
#			self.position = self.position.linear_interpolate(target_position+zoomoffset, speed*delta)
#			if (position-(target_position+zoomoffset)).length_squared() < 9:
#				self.position = target_position+zoomoffset
#				if target_scale != null:
#					scale = target_scale*1.5
#		if target_scale != null:
#			self.scale = self.scale.linear_interpolate(target_scale*1.5,speed*delta)	
#
	
	#zoom on mouseover
	#var rect = $CardFrame/Area2D/CollisionShape2D
	var mousedist = get_global_mouse_position() - $Resizer.get_global_transform().get_origin()
	var extents = Vector2(750, 1050)*$Resizer.get_global_transform().get_scale()
	#print(mousedist, extents)
	if mousedist.x < extents.x and mousedist.y < extents.y and mousedist.x > 0 and mousedist.y > 0:
		if controller.takeFocus(self):
			if $Resizer.scale.x ==1:
				$AnimationPlayer.play("Grow")
	else:
		if $Resizer.scale.x ==1.5:
			$AnimationPlayer.play_backwards("Grow")
		controller.releaseFocus(self)
func Triggered(method, argv, results) -> Dictionary:
	results = {}
	if triggers.has(method):
		if method == "endofturn":
			print("triggering "+ method + " on " + title)
		for code in triggers[method]:
			execute(code, argv)
	self.updateDisplay();
	return results
func Interrupts(method, args) -> bool:
	return false


func hasType(type)->bool:
	if type == "any":
		return true
	if types.has(type):
		return true
	return false
	
func hasName(string)->bool:
	return self.title.find(string)!=-1
	

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
		elif parsed[0] == "removetrigger":
			var removetrigger = parsed[1]
			Utility.addtoDict(triggers ,removetrigger[0], ["if", [removetrigger[1],["decrementRemoveCount"]]])
			removecount =removetrigger[2]
			defaultremovecount = removecount
			removetype = removetrigger[0]
			
		elif parsed[0] == "types":
			for type in parsed[1]:
				types[type] = true
		elif parsed[0] == "modifiers":
			for mod in parsed[1]:
				modifiers[mod] = true
		elif parsed[0] == "cost":
			self.cost = parsed[1][0]
			
			unmodifiedCost = cost
		elif parsed[0] =="text":
			self.text =  Utility.join(" ",parsed[1]).replace("\\n","\n")
		elif parsed[0] == "image":
			self.image = load(parsed[1][0])
		elif parsed[0] == "title":
			self.title = Utility.join(" ",parsed[1])
		elif parsed[0] == "rarity":
			self.rarity = int(parsed[1][0])
			
	#self.updateDisplay()
func execute(code, argv):
	
	if code is String:
		return code
	if not code[0] is String:
		assert(false, str(code[0]) + " is not a valid command" )
	if code [0] == "count":
		var arg1 = processArgs(code[1][0], argv)
		var arg2 = processArgs(code[1][1], argv)
		var result = controller.countTypes(code[1][0],code[1][1])
		return result
	elif code[0] == "countName":
		var arg1 = processArgs(code[1][0], argv)
		var arg2 = processArgs(code[1][1], argv)
		var result = controller.countNames(code[1][0],code[1][1])
		return result
	elif code[0] =="if":
		var condition
		if code[1][0] is Array:
			condition = code[1][0].duplicate()
		else:
			condition = code[1][0]
		var command = code[1][1]
		if condition is Array:
			var comp = condition.find(">")
			var compsymb = ">"
			if comp == -1:
				comp = condition.find("<")
				compsymb = "<"
			if comp ==-1:
				comp =condition.find("=")
				compsymb = "="
			if comp != -1:
			
				var before = condition.slice(0,comp-1)
				var after  = condition.slice(comp+1,condition.size()-1)
				if before.size() > 1:
					before = execute(before, argv)
				else:
					before = before[0]
				if after.size() > 1:
					after = execute(after, argv)
				else:
					after = after[0]
				if (compsymb == ">" and before > after) or (compsymb == "<" and before<after) or (compsymb == "=" and before == after):
					return execute(command, argv)
			else:
				if execute(condition, argv):
					return execute(command, argv)
		elif condition is bool:
			if condition:
				return execute(command, argv)
		else:
			if processArgs(condition, argv):
				return execute(command, argv)
	elif code[0] == "repeat":
		var times = processArgs(code[1][2],argv)
		for i in range(times):
			execute(code[1].split(0,1), argv)
	elif code[0] == "do":
		var args = []
		for arg in code[1][1]:
			args.append(processArgs(arg,argv))
		
		var silence = processArgs(code[1][2], argv)
		Utility.extendDict(results, controller.Action(code[1][0], args, silence))
	elif code[0] == "decrementRemoveCount":
		removecount -=1
		if removecount == 0:
			self.Triggered("onRemoveFromPlay",argv,results)
			controller.Action("move",["Play","Discard",self])
			self.cost = unmodifiedCost
			self.removecount = defaultremovecount
	elif code[0] == "hastype":
		var args = []
		for arg in code[1]:
			args.append(processArgs(arg,argv))
		return args[0].hasType(args[1])
	elif code[0] == "hasname":
		var args = []
		for arg in code[1][1]:
			args.append(processArgs(arg,argv))
		return args[0].hasName(args[1])
		
	else:
		#assert(false, code[0] + " not a valid command")
		return code
func processArgs(arg, argv):
	if arg is String:
		if arg.substr(0,5) == "argv[":
			return argv[int(arg[5])]
		if arg == "self":
			return self
		if arg =="true":
			return true
		if arg =="false":
			return false
		return arg
	elif arg is Array:
		return execute(arg, argv)
	else:
		return arg
func updateDisplay():
	
	get_node("Resizer/CardFrame/Cost").bbcode_text= "[center]" + str(cost) + "[/center]";
	get_node("Resizer/CardFrame/Title").bbcode_text= "[center]" + title+ "[/center]";
	get_node("Resizer/CardFrame/Text").bbcode_text = "[center]"+text+ "[/center]";
	get_node("Resizer/CardFrame/Timer").bbcode_text= "[center]" + str(removecount) + "[/center]";
	get_node("Resizer/CardFrame/arrow").visible =false
	get_node("Resizer/CardFrame/hourglass").visible = false
	get_node("Resizer/CardFrame/Endless").visible = false
	if removetype == "never":
		removecount = -1
		get_node("Resizer/CardFrame/Endless").visible = true
		get_node("Resizer/CardFrame/Timer").visible = false
	elif removetype == "endofturn":
		get_node("Resizer/CardFrame/hourglass").visible = true
	else:	
		get_node("Resizer/CardFrame/arrow").visible =true
	if $Resizer.scale.x > 1.1:
		$AnimationPlayer.play_backwards("Grow")
func deepcopy(other)-> Card:
	var properties = self.get_property_list()
	for prop in properties:
		var name = prop.name;
		var val = self.get(name);
		if val == null or not val is Object:
			other.set(name, val);
		elif not val is NodePath and val.has_method("duplicate"):
			val = val.duplicate(true)
	other.image = self.image
	other.controller = self.controller
	return other
		
func moveTo(pos:Vector2, size = null):
	if target_position == null:
		self.position = pos
		self.target_position = pos
		if size !=null:
			self.scale = size
	else:
		
		self.target_scale = size
		self.target_position = pos
	
		
func zoom() -> void:
	if $Resizer.scale.x == 1.5:
		$AnimationPlayer.play_backwards("Grow")
	elif $Resizer.scale.x == 1:
		$AnimationPlayer.play("Grow")

func _on_Area2D_mouse_entered() -> void:
	#mouseon = true
#	if target_position == null:
#		target_position  = position
#	if target_scale == null:
#		target_scale = scale
	#get_parent().get_parent().updateDisplay()
	#self.z_index+=1
	pass
	#zoom()
		
	
	#moveTo(self.target_position+Vector2(0,-100), self.target_scale*1.5)
	



func _on_Area2D_mouse_exited() -> void:
	#mouseon = false
	#zoom()
	pass
		
func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#mouseon = true
#	if $Resizer.scale.x == 1:
#		$AnimationPlayer.play("Grow")
	if event.is_action("left_click") and controller.inputdelay > .2:
		
		if get_parent().has_method("cardClicked"):
			get_parent().cardClicked(self)
		controller.inputdelay = 0
	
