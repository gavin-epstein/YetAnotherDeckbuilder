extends Node2D
class_name Card
var controller
#constants
const zoomoffset = Vector2(0,-100)
const speed  = 10
#vars
var triggers = {}
var interruptions ={}
var cost
var unmodifiedCost
var removecount
var defaultremovecount
var types = {}
var text
var image
var title
var modifiers = {}
var removetype
var target_scale
var target_position
var highlighted = false
var rarity = 0
var debug
var mouseoverdelay = 0
var mouseon
var vars = {}
var iconsdone = false
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

	
	#zoom on mouseover
	#var rect = $CardFrame/Area2D/CollisionShape2D
	var mousedist = get_global_mouse_position() - $Resizer.get_global_transform().get_origin()
	var extents = Vector2(750, 1050)*$Resizer.get_global_transform().get_scale()
	#print(mousedist, extents)
	if mousedist.x < extents.x and mousedist.y < extents.y and mousedist.x > 0 and mousedist.y > 0:
		if controller.takeFocus(self):
			if $Resizer.scale.x ==1:
				z_index = 20
				$AnimationPlayer.play("Grow")
	else:
		if $Resizer.scale.x ==1.5:
			$AnimationPlayer.play_backwards("Grow")
			z_index = 0
		controller.releaseFocus(self)
func Triggered(method, argv):
	
	if triggers.has(method):
		for code in triggers[method]:
			var res = execute(code, argv)
			if res is GDScriptFunctionState:
				res = yield(res, "completed")
	self.updateDisplay();

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
	
func hasModifier(string) -> bool:
	if string == "any":
		return true
	if modifiers.has(string):
		return true
	return false
func hasVariable(string) ->bool:
	if string == "any":
		return true
	if vars.has("$"+string):
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
		elif parsed[0][0] =="$":
			vars[parsed[0]] = parsed[2]
	#self.updateDisplay()
func execute(code, argv):
	
	if code is String:
		return code
	if code is GDScriptFunctionState:
		code = yield(code, "completed")
	if not code[0] is String:
		return code
		#assert(false, str(code[0]) + " is not a valid command" )
	if code [0] == "count":
		var arg1 = processArgs(code[1][0], argv)
		while arg1 is GDScriptFunctionState:
			yield(controller, "resumeExecution")
			arg1  = arg1.resume()
		var arg2 = processArgs(code[1][1], argv)
		while arg2 is GDScriptFunctionState:
			yield(controller, "resumeExecution")
			arg2  = arg2.resume()
		var result = controller.countTypes(code[1][0],code[1][1])
		return result
	elif code[0] == "countName":
		var arg1 = processArgs(code[1][0], argv)
		if arg1 is GDScriptFunctionState:
			arg1 = yield(arg1, "completed")
			
		var arg2 = processArgs(code[1][1], argv)
		if arg2 is GDScriptFunctionState:
			arg2 = yield(arg2, "completed")
		var result = controller.countNames(code[1][0],code[1][1])
		return result
	elif code[0] =="countModifier":
		var arg1 = processArgs(code[1][0], argv)
		if arg1 is GDScriptFunctionState:
			arg1 = yield(arg1, "completed")
			
		var arg2 = processArgs(code[1][1], argv)
		if arg2 is GDScriptFunctionState:
			arg2 = yield(arg2, "completed")
		var result = controller.countModifiers(code[1][0],code[1][1])
		return result
	elif code[0] =="if":
		var condition
		if code[1][0] is Array:
			condition = code[1][0].duplicate()
		else:
			condition = code[1][0]
		var command = code[1][1]
		#Check if it is a comparison
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
					if before is GDScriptFunctionState:
						before = yield(before, "competed")
						before  = before.resume()
				else:
					before = processArgs(before[0],argv)
				if after.size() > 1:
					after = execute(after, argv)
					if after is GDScriptFunctionState:
						after = yield(after, "completed")
						
				else:
					after = processArgs(after[0],argv)
				if (compsymb == ">" and before > after) or (compsymb == "<" and before<after) or (compsymb == "=" and before == after):
					var ex = execute(command, argv)
					if ex is GDScriptFunctionState:
						ex = yield(ex, "completed")
					return ex
			else:
				#no comparator found
				var cond = processArgs(condition, argv)
				if cond is GDScriptFunctionState:
					cond = yield(cond, "completed")
					
				if cond:
					var ex = execute(code[1][1], argv)
					while ex is GDScriptFunctionState:
						yield(controller, "resumeExecution")
						ex  = ex.resume()
					return ex
		elif condition is bool:
			if condition:
				var ex = execute(code[1].split(0,1), argv)
				while ex is GDScriptFunctionState:
					yield(controller, "resumeExecution")
					ex  = ex.resume()
				return ex
		else:
			#Simple condition
			var cond = processArgs(condition, argv)
			while cond is GDScriptFunctionState:
				yield(controller, "resumeExecution")
				cond  = cond.resume()
			if cond:
				var ex = execute(command, argv)
				while ex is GDScriptFunctionState:
					yield(controller, "resumeExecution")
					ex  = ex.resume()
				return ex
	elif code[0] == "repeat":
		var times = processArgs(code[1][1],argv)
		if times is GDScriptFunctionState:
			times = yield(times, "complete")
		for _i in range(times):
			var ex = execute(code[1][0], argv)
			if ex is GDScriptFunctionState:
				ex = yield(ex, "completed")
				
	elif code[0] == "do":
		var args = []
		for arg in code[1][1]:
			arg = processArgs(arg,argv)
			if arg is GDScriptFunctionState:
				arg =  yield(arg, "completed")
			args.append(arg)
		var silence = false
		if code[1].size()>2:
			silence = processArgs(code[1][2], argv)
			if silence is GDScriptFunctionState:
				silence = yield(silence, "completed")
		
		var res = controller.Action(code[1][0], args, silence)
		if res is GDScriptFunctionState:
			res = yield(res, "completed")
		
	elif code[0] == "decrementRemoveCount":
		removecount -=1
		if removecount == 0:
			self.Triggered("onRemoveFromPlay",argv)
			controller.Action("move",["Play","Discard",self])
			self.cost = unmodifiedCost
			self.removecount = defaultremovecount
	elif code[0] == "hastype":
		var args = []
		for arg in code[1]:
			arg = processArgs(arg,argv)
			if arg is GDScriptFunctionState:
				arg = yield(arg, "complete")
			args.append(arg)
		if not args[0].has_method("isCard"):
			return false
		return args[0].hasType(args[1])
	elif code[0] == "hasname":
		var args = []
		for arg in code[1]:
			arg = processArgs(arg,argv)
			if arg is GDScriptFunctionState:
				arg = yield(arg, "complete")
			args.append(arg)
		if not args[0].has_method("isCard"):
			return false
		return args[0].hasName(args[1])
	elif code[0] == "hasModifier" or code[0] == "hasmod":
		var args = []
		for arg in code[1]:
			arg = processArgs(arg,argv)
			if arg is GDScriptFunctionState:
				arg = yield(arg, "complete")
			args.append(arg)
		if not args[0].has_method("isCard"):
			return false
		return args[0].hasModifier(args[1])
	elif code[0] == "hasVariable" or code[0] == "hasvar":
		var args = []
		for arg in code[1]:
			arg = processArgs(arg,argv)
			if arg is GDScriptFunctionState:
				arg = yield(arg, "complete")
			args.append(arg)
		if not args[0].has_method("isCard"):
			return false
		return args[0].hasVariable(args[1])
	elif code[0] =="select":
		var args = []
		var arg = processArgs(code[1][0],argv)
		if arg is GDScriptFunctionState:
			arg = yield(arg, "completed")
		
		args.append(arg)
		args.append(code[1][1])
		arg = processArgs(code[1][2],argv)
		if arg is GDScriptFunctionState:
			arg = yield(arg, "completed")
		args.append(arg)
		if code[1].size()>3:
			arg = processArgs(code[1][3],argv)
			while arg is GDScriptFunctionState:
				yield(controller, "resumeExecution")
				arg  = arg.resume()
		var ret = controller.callv("select", args)
		if ret is GDScriptFunctionState:
			ret = yield(ret, "completed")
		return ret
		
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
		if arg[0] == "$" and vars.has(arg):
			return vars[arg]
		return arg
	elif arg is Array:
		var ret = execute(arg, argv)
		if ret is GDScriptFunctionState:
			ret = yield(ret, "completed");
		return ret
	else:
		return arg
func updateDisplay():
	
	get_node("Resizer/CardFrame/Cost").bbcode_text= "[center]" + str(cost) + "[/center]";
	get_node("Resizer/CardFrame/Title").bbcode_text= "[center]" + title+ "[/center]";
	var displaytext = text
	for key in vars:
		displaytext = displaytext.replace(key, vars[key])
	get_node("Resizer/CardFrame/Text").bbcode_text = "[center]"+displaytext+ "[/center]";
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
		
func moveTo(pos:Vector2, size = null):
	if target_position == null:
		self.position = pos
		self.target_position = pos
		if size !=null:
			self.scale = size
	else:
		
		self.target_scale = size
		self.target_position = pos
	
func highlight():
	self.highlighted = true
	$Resizer/CardHighlight.visible = true
func dehighlight():
	self.highlighted = false
	$Resizer/CardHighlight.visible = false

		
func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#mouseon = true
#	if $Resizer.scale.x == 1:
#		$AnimationPlayer.play("Grow")
	if event.is_action("left_click") and controller.inputdelay > .2:
		
		if get_parent().has_method("cardClicked"):
			get_parent().cardClicked(self)
		controller.inputdelay = 0
func isCard():
	return true	

func isIdentical(other):
	if self.title != other.title:
		return false
	#todo add modified values here
	return true
