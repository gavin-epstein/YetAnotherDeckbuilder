extends Map
var playerNode
var frognode;
var frog2node;
var step = -1;
signal nextstep;

func _process(delta: float) -> void:
#	if randf()<.01:
#		print("step:", step)
	if step == 0:
		if cardController.Hand.cards.size()==0:
			step+=1
			emit_signal("nextstep")
	elif step == 1:
		if cardController.Hand.cards.size()==1:	
			step+=1
			emit_signal("nextstep")
	elif step == 2:
		if cardController.Hand.cards.size()==0:	
			step+=1
			emit_signal("nextstep")
	elif step == 3:
		if cardController.Hand.cards.size()==1:
			step+=1
			emit_signal("nextstep")
	elif step == 4:
		if cardController.Hand.cards.size()==0:
			step+=1
			emit_signal("nextstep")
	elif step == 5:
		if cardController.Hand.cards.size()==1:
			step+=1
			emit_signal("nextstep")
	elif step == 6:
		if cardController.Hand.cards.size()==0:
			step+=1
			emit_signal("nextstep")
	elif step == 7:
		if cardController.Hand.cards.size()==5:
			step+=1
			emit_signal("nextstep")
	elif step == 8:
		if frog2node.occupants.size()==0 and cardController.Energy == 0:
			step+=1
			emit_signal("nextstep")
	elif step == 9:
		if get_node("/root/Scene/Center/MapLayer").zoomfactor <1.79:
			step+=1
			emit_signal("nextstep")
	
	

func generate() -> void:
	var maxDist = sqrt(maxSqDist)
	voidNode = addGridNode(Vector2(width/2,0),-1, true)
	for x in range(-width, width,maxDist):
		var pos = Vector2(x,-height-40)
		var color  = -1
		sentinels.append(addGridNode(pos, color,true))
		pos = Vector2(x,height+40)
		
		sentinels.append(addGridNode(pos, color,true))
		#second row
		pos = Vector2(x,-height-sentinelrowsep)
		addGridNode(pos, color,true)
		pos = Vector2(x,height+sentinelrowsep)
		addGridNode(pos, color,true)
	for y in range(-height, height, maxDist):
		var pos = Vector2(-width-40, y)
		var color  = -1
		sentinels.append(addGridNode(pos, color,true))
		pos = Vector2(width+40, y)
		color  = -1
		sentinels.append(addGridNode(pos, color,true))
		#outer row
		pos = Vector2(-width-sentinelrowsep, y)	
		addGridNode(pos, color,true)
		pos = Vector2(width+sentinelrowsep, y)
		addGridNode(pos, color,true)
	var count = 0
	for x in range( maxDist-width,0, maxDist):
		#bottom row
		var pos = Vector2(x,maxDist)
		var color  = -1
		sentinels.append(addGridNode(pos, color,true))
		#middle
		pos = Vector2(x,0)
		color  = 0
		var node = addGridNode(pos, color)
		if (count ==0):
			playerNode = node
		elif (count == 2):
			frognode=node
		elif (count == 3):
			frog2node=node
		#top row 
		pos = Vector2(x,-maxDist)
		color  = -1
		sentinels.append(addGridNode(pos, color,true))
		count+=1
	for x in range( 0, width - maxDist, maxDist-10):
		for y in range(-height, height, maxDist-10):
			var pos = Vector2(x,y)
			var color = 3
			var node = addGridNode(pos, color);
	triangulate()


func Load2():
	get_node("/root/Scene/Center/MapLayer").zoomfactor = 1.8
	get_node("/root/Scene/Center/MapLayer").targetpos = Vector2(1800, 510)
	var res = doPhysics(2);
	if res is GDScriptFunctionState:
		res = yield(res,"completed")
	step=0
	enemyController.addPlayerAndVoid(playerNode)
	enemyController.Summon( frognode,"Frog Warrior")
	enemyController.Summon( frog2node,"Moss Spore")
	frog2node.occupants[0].setStatus("stunned", 0);
	emit_signal("mapGenerated")
	
	
func tutorial():
	#step 0
	#cards in hand 1
	enemyController.Player.say("Hi, I'm Mora",-1)
	message("Click on the card Quickstep to move Mora")
	yield(self, "nextstep")
	#step 1
	#playing quickstep, cards in hand 0
	enemyController.Player.say("Everything I do is accomplished by playing cards.",-1)
	yield(self,"nextstep")
	#step 2
	#cards in hand, meat cleaver
	enemyController.Player.say("",0)
	message("Oh no, there's an enemy in your way. Play an attack to kill it.")
	yield(self,"nextstep")
	#step 3:
	#playing meat cleaver, cards in hand 0
	yield(self,"nextstep")
	#step 4:
	#cards in hand: loot
	enemyController.Player.say("Ooh, it dropped some loot",-1)
	message("Play the loot to open it")
	yield(self,"nextstep")
	#step 5:
	#playing loot:
	#cards in hand - none
	enemyController.Player.say("",0)
	message("Pick any card. You can right click on a card for more info about it")
	yield(self,"nextstep")
	#step 6:
	#cards in hand: a block card
	frog2node.occupants[0].say("The swords above my head mean I'm gonna attack",-1)
	enemyController.Player.say("Hover over any unit for more info about it",-1)
	message("Play a card to block incoming damage")
	yield(self,"nextstep")
	#step 7:
	#cards in hand: none
	frog2node.occupants[0].say("",-1)
	enemyController.Player.say("I have no cards in hand",-1)
	message("Press end turn to draw a new hand and refill your energy")
	yield(self,"nextstep")
	#step 8:
	message("Kill the Moss Spore and move past it to continue ")
	enemyController.Player.say("",0)
	yield(self,"nextstep")
	#step 9:
	message("You are out of energy, end your turn")
	enemyController.Player.say("The energy cost of each card is in the top left corner",-1)
	yield(self, "nextstep")
	#step 10
	message("Scroll right to see your next challenge")
	enemyController.Player.say("Use WASD to scroll the map, Q and E to zoom",-1)
	yield(self,"nextstep")
	#step 11:
	enemyController.Player.say("",-1)
	enemyController.theVoid.say("I am The Void, I will devour the world")
	message("To save the world you must defeat The Void")
func message(message):
	if message == "":
		get_node("/root/Scene/Message").visible = false
		return
	get_node("/root/Scene/Message/Message").bbcode_text = "[center]"+message+"[/center]"
	get_node("/root/Scene/Message").visible = true
	
	
