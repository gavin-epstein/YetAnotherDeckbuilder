extends Node2D
class_name Executable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var controller
var triggers = {}
var interrupts = {}
var vars = {}

func Triggered(method, argv):
	
	if triggers.has(method):
		var oldallowed = controller.cardController.inputAllowed
		controller.cardController.inputAllowed=false
		for code in triggers[method]:
			var res = execute(code, argv)
			if res is GDScriptFunctionState:
				res = yield(res, "completed")
			if res and method!="onPlay" and self.has_method("isCard"):
				$AnimationPlayer.play("Triggered")
		controller.cardController.inputAllowed = oldallowed
		if not controller.test:
			self.updateDisplay();
func Interrupts(method, argv) -> bool:
	if interrupts.has(method):
		var reslist = []
		for code in interrupts[method]:
			var res = execute(code, argv)
			if res is GDScriptFunctionState:
				res = yield(res, "completed")
			reslist.append(res)
		#Take the first result as the value
		#So do without interrupting should look like
		#interrupt(method, false)
		#interrupt(method, do( ... ))
		print(reslist)
		for res in reslist:
			if res is bool:
				return res
	return false
			
func updateDisplay():
	assert(false, "Abstract Method")

func execute(code, argv):
	
	if code is String:
		return processArgs(code,argv)
	if code is GDScriptFunctionState:
		code = yield(code, "completed")
	if not code[0] is String:
		return code
		#assert(false, str(code[0]) + " is not a valid command" )
	if code [0] == "count":
		var arg1 = processArgs(code[1][0], argv)
		if arg1 is GDScriptFunctionState:
			arg1 = yield(arg1, "completed")
		var arg2 = processArgs(code[1][1], argv)
		if arg2 is GDScriptFunctionState:
			arg2  = yield(arg2, "completed")
		var result = controller.countTypes(code[1][0],code[1][1])
		return result
	elif code[0] == "countName" or code[0] == "countNames":
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
		var result = controller.countModifiers(arg1,arg2)
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
				if (Utility.type(before) == Utility.type(after)) and ((compsymb == ">" and before > after) or (compsymb == "<" and before<after) or (compsymb == "=" and before == after)):
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
					if ex is GDScriptFunctionState:
						ex = yield(ex,"completed")
					return ex
		elif condition is bool:
			if condition:
				var ex = execute(code[1].split(0,1), argv)
				if ex is GDScriptFunctionState:
					ex = yield(ex,"completed")
				return ex
		else:
			#Simple condition
			var cond = processArgs(condition, argv)
			if cond is GDScriptFunctionState:
				cond = yield(cond, "completed")
				
			if cond:
				var ex = execute(command, argv)
				if ex is GDScriptFunctionState:
					ex = yield(ex,"completed")
				return ex
		return false
	elif code[0] == "repeat":
		var times = processArgs(code[1][1],argv)
		if times is GDScriptFunctionState:
			times = yield(times, "complete")
		for _i in range(times):
			var ex = execute(code[1][0], argv)
			if ex is GDScriptFunctionState:
				ex = yield(ex, "completed")
				
	elif code[0] == "do" or code[0] == "enemyDo" or code[0] == "cardDo":
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
		var res
		if code[0] == "do":
			res = controller.Action(code[1][0], args, silence)
		elif code[0] == "enemyDo":
			res = controller.enemyController.Action(code[1][0], args, silence)
		elif code[0] == "cardDo":
			res = controller.enemyController.cardController.Action(code[1][0], args, silence)
		if res is GDScriptFunctionState:
			res = yield(res, "completed")
		return res
	elif code[0] == "decrementRemoveCount":
		if hasVariable("removecount"):
			vars["$removecount"] = vars["$removecount"]-1 
			if vars["$removecount"] <= 0:
				var res = self.Triggered("onRemoveFromPlay",argv)
				if res is GDScriptFunctionState:
					yield(res, "completed")
				controller.Action("move",["Play","Discard",self])
				vars["$Cost"] = vars["$BaseCost"]
				vars["$removecount"] = vars["$defaultremovecount"]
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
	elif code[0] == "hasname" or code[0]=="hasName":
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
		if not args[0].has_method("hasVariable"):
			return false
		return args[0].hasVariable(args[1])
	elif code[0] =="select":
		var args = []
		var arg = processArgs(code[1][0],argv)
		if arg is GDScriptFunctionState:
			arg = yield(arg, "completed")
		
		args.append(arg)
		if self.has_method("isCard"):
			arg = code[1][1]
		else:
			arg = processArgs(code[1][1],argv)
			if arg is GDScriptFunctionState:
				arg = yield(arg, "completed")
		args.append(arg)

		for i in range (2,7):
			if code[1].size()>i:
				arg = processArgs(code[1][i],argv)
				if arg is GDScriptFunctionState:
					arg = yield(arg,"completed")
				args.append(arg)
		var ret = controller.callv("select", args)
		if ret is GDScriptFunctionState:
			ret = yield(ret, "completed")
		return ret
	elif code[0] == "foreach":
		var list = processArgs(code[1][1],argv)
		if list is GDScriptFunctionState:
			yield(list,"completed")
		var res = foreach(code[1][0],list,code[1][2],argv)
		if res is GDScriptFunctionState:
			res = yield(res,"completed")
		return res
	elif code[0] == "*":
		var arg1 = processArgs(code[1], argv)
		if arg1 is GDScriptFunctionState:
			arg1 = yield(arg1, "completed")
			
		var arg2 = processArgs(code[2], argv)
		if arg2 is GDScriptFunctionState:
			arg2 = yield(arg2, "completed")
		if arg1 != null and arg2 !=null:
			return arg1*arg2
		else:
			return 0
	elif code[0] == "+":
		var arg1 = processArgs(code[1], argv)
		if arg1 is GDScriptFunctionState:
			arg1 = yield(arg1, "completed")
			
		var arg2 = processArgs(code[2], argv)
		if arg2 is GDScriptFunctionState:
			arg2 = yield(arg2, "completed")
		if arg1 != null and arg2 !=null:
			return arg1+arg2
		else:
			return 0
	elif code[0] == "!" or code[0] == "not":
		var arg = processArgs(code.slice(1,code.size()-1), argv)
		if arg is GDScriptFunctionState:
			arg = yield(arg,"completed")
		if arg is bool:
			return not arg
		else:
			return false
	elif code[0] == "random":
		var choice = Utility.choice(code[1])
		choice = processArgs(choice,argv)
		if choice is GDScriptFunctionState:
			choice = yield(choice,"completed")
		return choice
	elif code[0] == "hasStatus" or code[0] == "hasProperty":
		var arg1 = processArgs(code[1][0], argv)
		if arg1 is GDScriptFunctionState:
			arg1 = yield(arg1, "completed")
			
		var arg2 = processArgs(code[1][1], argv)
		if arg2 is GDScriptFunctionState:
			arg2 = yield(arg2, "completed")
		if arg1 != null and arg1.has_method("hasProperty"):
			return arg1.hasProperty(arg2)
		else:
			return false
	elif code[0] == "getDamage":
		var args  = []
		for arg in code[1]:
			arg = processArgs(arg, argv)
			if arg is GDScriptFunctionState:
				arg = yield(arg,"completed")
			args.append(arg)
		if args.size() == 0 and self.has_method("getStrength"):
			return self.call("getStrength")
		elif args.size() == 1:
			if self.has_method("getStrength"):
				return self.call("getStrength",args[0])
			else:
				if controller.enemyController.Player == null:
					return 0
				return controller.enemyController.Player.getStrength(args[0])
		elif args.size() == 2 and args[0].has_method("getStrength"):
			return args[0].getStrength(args[1])
		else:
			return 0
	else:
		var ret = []
		for arg in code:
			arg = processArgs(arg, argv)
			if arg is GDScriptFunctionState:
				arg = yield(arg,"completed")
			ret.append(arg)
		return ret
		
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
		if arg[0] == "$":
			if vars.has(arg):
				return vars[arg]
			else:
				return false
		if arg == "tile" and self.get("tile")!=null:
			return self.tile
		if arg == "Player":
			if controller.enemyController.Player !=null:
				return controller.enemyController.Player.tile
			return null
		if arg == "windDirection":
			return controller.enemyController.windDirection
		if arg == "null":
			return null
		if arg == "strength" and self.get("strength")!=null :
			return self.get("strength")
		if arg == "range" and self.get("attackrange")!=null :
			return self.get("attackrange")
		if arg == "speed" and self.get("speed")!=null :
			return self.get("speed")
		return arg
	elif arg is Array:
		var ret = execute(arg, argv)
		if ret is GDScriptFunctionState:
			ret = yield(ret, "completed");
		return ret
	else:
		return arg
func hasVariable(string) ->bool:
	if string == "any":
		return true
	if vars.has("$"+string):
		return true
	return false

func foreach(varname,list,action,argv):
	if list == null:
		return false
	if not list is Array:
		list = [list]
	var reslist = []
	for item in list:
		vars["$"+varname] = item
		var res = execute(action,argv)
		if res is GDScriptFunctionState:
			res = yield(res,"completed")
		reslist.append(res)
	vars.erase(varname)
	return reslist
