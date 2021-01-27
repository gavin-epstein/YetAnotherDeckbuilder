extends Node2D
export var difficulty: int
export var health: int
export var status = {}
export var title:String
export var strength = 0
var speed = 5
var spawnableTerrains = {}
var healthBarTemplate = preload("res://HealthBar.tscn")
var healthBar
var block = 0
var armor = 0
var maxHealth
var tile
var nextTurn =[]
#n the node enters the scene tree for the first time.
func _ready()-> void:
	onSummon()
func onSummon()->void:
	addHealthBar()
	maxHealth  = health
func _process(delta: float) -> void:
	if tile != null and (self.position - tile.position).length_squared()>100:
		self.position  += (tile.position - self.position)*speed*delta
	self.z_index = (500+position.y)/10;

func takeTurn():
	print(self.title + " " + str(nextTurn))
	for move in nextTurn:
		if move[0] == "move":
			if move[1].occupants.size()==0:
				get_parent().move(self, move[1])
		elif move[0] == "attack":
			var types = move[2]
			var damage = move[3]
			if status.has("flaming"):
				types.append("fire")
				damage = damage*1.5
			if move[1].occupants.size()!=0:
				move[1].occupants[0].takeDamage(damage,types,self)
		elif move[0] == "takeDamage":
			takeDamage(move[1], move[2], null)
#Eg. [move, tile]
#[attack, tile, [fire],3]
#[takeDamage, amount, types]
func getNextTurn():
	pass


func Damaged(amount,types,attacker):
	pass
func addHealthBar():
	healthBar  = healthBarTemplate.instance()
	healthBar.scale = Vector2(.65,.65);
	healthBar.position = Vector2(0,220);
	add_child(healthBar)
	updateDisplay()
	
func hasProperty(prop):
	if prop == 'any' or prop == "exists" or prop == "notPlayer":
		return true
	elif prop == self.title:
		return true
	elif status.has(prop):
		return true
	return false
func takeDamage(amount,types, attacker):
	#set enemies on fire, if they are flammable and in water
	if "fire" in types and status.has("flammable") and not Utility.interpretTerrain("water") == tile.terrain:
		status["flaming"] = true
	#put out fire
	if ("water" in types or "ice" in types) and status.has("flaming"):
		status.erase("flaming")
	for type in types:
		if status.has("immune") and type in status.immune:
			amount = 0
			break
		if status.has("resistant") and type in status.resistant:
			amount = amount/2.0
			break
	for type in types:
		if status.has("vulnerable") and type in status.vulnerable:
			amount = amount*1.5
	if armor > 0:
		amount =max(amount -  armor, 0)
		armor -=1
	if block >amount:
		block -=floor(amount)
		amount = 0
	elif block > 0:
		amount -= block
		block = 0
	
		
	health -= floor(amount)
	self.Damaged(amount,types,attacker)
	if health <= 0:
		die(attacker)
	else:
		updateDisplay()
	return amount
func startOfTurn():
	if status.has("flaming") and not status.has("fireproof"):
		takeDamage(floor(health/2),["fire"],null)
func endOfTurn():
	pass

func updateDisplay():
	healthBar.get_node("Heart/Number").bbcode_text = "[center]"+str(health)+"[/center]"
	healthBar.get_node("Block/Number").bbcode_text = "[center]"+str(block)+"[/center]"
	healthBar.get_node("Armor/Number").bbcode_text = "[center]"+str(armor)+"[/center]"
	healthBar.get_node("Attack/Number").bbcode_text = "[center]"+str(strength)+"[/center]"
	if block > 0:
		healthBar.get_node("Block").visible = true
	else:
		healthBar.get_node("Block").visible = false
	if armor > 0:
		healthBar.get_node("Armor").visible = true
	else:
		healthBar.get_node("Armor").visible = false
	if  strength > 0:
		healthBar.get_node("Attack").visible = true
	else:
		healthBar.get_node("Attack").visible = false
func die(attacker):
	if status.has("supplying") and attacker != null:
		attacker.gainStrength(self.strength)
	if status.has("nourishing") and attacker != null:
		attacker.gainMaxHealth(self.maxHealth)
	if status.has("explosive"):
		#damage all adjacent enemies
		for node in get_parent().map.selectAll(self.tile,1,"exists",["any"]):
			node.occupants[0].takeDamage(status.explosive,("explosive"),self)
	self.visible = false
	tile.occupants.erase(self)
	get_parent().units.erase(self)
func gainMaxHealth(amount):
	self.maxHealth +=amount
	self.health += amount
	updateDisplay()
func gainStrength(amount):
	self.strength+=amount
	updateDisplay()
func addArmor(amount):
	armor+=amount
	updateDisplay()
func addBlock(amount):
	block+=amount
	updateDisplay()
