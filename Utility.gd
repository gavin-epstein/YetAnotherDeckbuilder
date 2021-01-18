class_name Utility


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
