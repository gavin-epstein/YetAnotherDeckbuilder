extends Map
var playerNode
var frognode;
var frog2node;
var step = -1;
signal nextstep;

func _process(delta: float) -> void:
	if randf()<.01:
		print("step:", step)
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
		
		if frog2node.occupants.size()>0  and frog2node.occupants[0].health<7 and cardController.focus == null:
			message("It has taken damage, but it's not quite dead")
			enemyController.Player.say("Hit it again!",-1)
		
		if frog2node.occupants.size()==0 and cardController.Energy > 0 and cardController.focus == null:
			message("Dash forward to continue")
			enemyController.Player.say("")
		if frog2node.occupants.size()==0 and cardController.Energy == 0 and cardController.focus != self:
			cardController.releaseFocus(self)
			step+=1
			emit_signal("nextstep")
	elif step == 9:
		if cardController.Energy  >0 :
			step+=1
			emit_signal("nextstep")
	elif step == 10:
		if get_node("/root/Scene/Center/MapLayer").zoomfactor <1.79 or get_node("/root/Scene/Center/MapLayer").targetpos.x < 1300 :
			step+=1
			emit_signal("nextstep")
	elif step == 11:
		if enemyController.theVoid.armor < 10:
			step+=1
			emit_signal("nextstep")
	elif step == 12:
		if get_node("/root/Scene/CardController/CardDisplay").visible==true:
			step+=1
			emit_signal("nextstep")
	elif step == 13:
		if get_node("/root/Scene/CardController/CardDisplay").visible==false:
			step+=1
			emit_signal("nextstep")
	elif step == 14:
		var advance = true
		for card in cardController.Hand.cards:
			if card.title =="Fly":
				advance = false
				break
		if advance:
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
	get_node("/root/Scene/morahealthbar").visible = false
	get_node("/root/Scene/voidhealthbar").visible = false
	get_node("/root/Scene/Center/MapLayer").zoomfactor = 1.8
	get_node("/root/Scene/Center/MapLayer").targetpos = Vector2(1500, 510)
	var res = doPhysics(2);
	if res is GDScriptFunctionState:
		res = yield(res,"completed")
	enemyController.addPlayerAndVoid(playerNode)
	enemyController.Summon( frognode,"Frog Warrior")
	enemyController.Summon( frog2node,"Moss Spore")
	frog2node.occupants[0].setStatus("stunned", 0);
	emit_signal("mapGenerated")
	
	
func tutorial():
	#step -1
	message("Press esc to Pause and open the menu, then hit Resume")
	yield(get_node("/root/Scene/Pause Menu"),"unpaused")
	step = 0
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
	message("Oh no, there's an enemy in your way. Play an attack card to kill it.")
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
	message("Pick any card.")
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
	message("Kill the Moss Spore and Dash past it to continue ")
	enemyController.Player.say("",0)
	yield(self,"nextstep")
	#step 9:
	message("You are out of energy, end your turn")
	enemyController.Player.say("The energy cost of each card is in the top left corner",-1)
	yield(self, "nextstep")
	#step 10
	message("Scroll right and Zoom out to see your next challenge")
	enemyController.Player.say("Use WASD or arrow keys to scroll the map, Q and E to zoom",-1)
	yield(self,"nextstep")
	#step 11:
	enemyController.Player.say("I must defeat The Void to save the world",-1)
	enemyController.theVoid.say("I am The Void, I will devour the world",-1)
	message("Attack The Void")
	yield(self,"nextstep")
	#step 12
	enemyController.Player.say("When the Void grows, it consumes the tile its tentacles point to",-1)
	enemyController.theVoid.say("I consume whenever the void card in play is triggered. Right click on 'Void of Vengeance' to find out more",-1)
	message("The Void lost some armor, and ate a tile in response!")
	yield(self,"nextstep")
	#13
	#looking at card
	message("")
	enemyController.Player.say("",-1)
	enemyController.theVoid.say("",-1)
	yield(self,"nextstep")
	#14
	enemyController.Player.say("You can right click any card to get more info",-1)
	#end of tutorial
	cardController.Action("create",["Fly","Hand"])
	message("Play Fly to end the tutorial")
	yield(self,"nextstep")
	enemyController.Win()

func message(message):
	if message == "":
		get_node("/root/Scene/Message").visible = false
		return
	get_node("/root/Scene/Message/Message").bbcode_text = "[center]"+message+"[/center]"
	get_node("/root/Scene/Message").visible = true
	
	
