class_name Utility
enum Terrain{Grass, Stone, Water}

static func parseCardCode(string):
	var regex = RegEx.new()
	regex.compile("^[A-Za-z0-9]$")
	var currenttoken =""
	var tokens = []
	var parenstack = 0
	var instring = false
	for letter in string:
		
		if letter == ")":
			parenstack -= 1
		
		if parenstack > 0 or regex.search(letter) or letter in ["[","]"] :
			currenttoken+=letter #if its a letter, or in parenthesis, smash on the current token
		elif instring:
			if not letter == '"':
				currenttoken +=letter
		elif letter == ")":	
			tokens.append(parseCardCode(currenttoken))
			currenttoken = ""
		
		else:
			if currenttoken !="":
				tokens.append(currenttoken)
			if not letter in [",","(",")"," ", '"']:
				tokens.append(letter)
			currenttoken = ""
		if letter == "(":
			parenstack +=1
		if letter == '"':
			#print(instring)
			instring = not instring
		
	tokens.append(currenttoken)
	var newtokens = []
	for token in tokens:
		
		if not token is Array and token.is_valid_integer():
			newtokens.append(int(token))
		elif (token is String and token != "") or token is Array :
			newtokens.append(token)
		
	return newtokens
	
static func join(string, array) -> String:
	var out = ""
	for s in array:
		out += string +str(s)
	return out.right(string.length())
static func addtoDict(results:Dictionary, key, val):
	if not results.has(key):
		results[key] = []
	
	results[key].append(val)
	return results
static func extendDict(dict1:Dictionary, dict2:Dictionary):
	for key in dict2.keys():
		if dict2[key] is Array:
			for val in dict2[key]:
				addtoDict(dict1, key, val)
		else:
			dict1[key] = dict2[key]
static func vecEqual(v1:Vector2, v2:Vector2) -> bool:
	return abs(v1.x-v2.x)<.01 and abs(v1.y-v2.y)<.01
static func getCircumcenter(A:Node2D, B:Node2D, C:Node2D) -> Vector2:
	var x1 = A.position.x
	var x2 = B.position.x
	var x3 = C.position.x
	var y1 = A.position.y
	var y2 = B.position.y
	var y3 = C.position.y
	var a = det3lastcolis1(x1,y1,x2,y2,x3,y3)
	if a == 0:
		return getCentroid(A,B,C)
	var sq1 = x1*x1+y1*y1
	var sq2 = x2*x2+y2*y2
	var sq3 = x3*x3+y3*y3
	var bx =  .5*determinant3(sq1,y1,1.0, sq2,y2,1.0, sq3,y3,1.0)
	var by = -.5* determinant3(sq1,x1,1.0, sq2,x2,1.0, sq3,x3,1.0)
	var ret = Vector2(bx/a, by/a)
#	
	return ret
static func getCentroid(A:Node2D, B:Node2D, C:Node2D) -> Vector2:
	return (A.position+B.position+C.position)/3
static func determinant3(a,b,c,d,e,f,g,h,i)-> float:
	# a b c 
	# d e f 
	# g h i
	return a*(e*i - f*h) + b*(f*g-d*i) + c*(d*h-e*g) 
static func det3lastcolis1(a,b,d,e,g,h)-> float:
	#a b 1
	#d e 1
	#g h 1
	return  a*e+b*g + d*h - a*h - b*d - e*g
static func getAngle(a:Node2D, b:Node2D, c:Node2D) -> float:
	var ba = b.position-a.position
	var bc = b.position-c.position
	var angle =  ba.angle() - bc.angle()
	if angle < -PI:
		return 2*PI+angle
	if angle > PI:
		return angle - 2 * PI
	return angle
#static func angleSum(A:Node2D, B:Node2D, C:Node2D,D:Node2D ) -> float:
#	return abs(getAngle(B,A,C)) + abs(getAngle(B,D,C))	
static func sqDistToNode(pixel:Vector2, node) -> float:
	var xDist = pixel.x   - node.position.x
	var yDist = pixel.y   - node.position.y
	return xDist*xDist + yDist * yDist
static func interpretTerrain(name)->int:
	if name == "grass":
		return 0
	elif name == "stone":
		return 1
	elif name == "water":
		return 2
	return -1
