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
	if status.has("lifelink"):
		var sumMaxHealth = self.maxHealth
		var sumHealth = self.health
		for unit in get_parent().units:
			if unit.title == self.title:
				sumMaxHealth +=unit.maxHealth
				sumHealth += unit.health
				break
		print(sumHealth, "/",sumMaxHealth)
		self.maxHealth = sumMaxHealth
		self.health = sumHealth
		self.updateDisplay()
		for unit in get_parent().units:
			if unit.title == self.title:
				unit.maxHealth = sumMaxHealth
				unit.health = sumHealth
				unit.updateDisplay()
			
func _process(delta: float) -> void:
	if tile != null and (self.position - tile.position).length_squared()>100:
		self.position  += (tile.position - self.position)*speed*delta
	self.z_index = (500+position.y)/10;

func takeTurn():
	print(title+" " +str(armor))
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

func getNextTurn():
	pass


func Damaged(amount,types,attacker):
	pass
func addHealthBar():
	healthBar  = healthBarTemplate.instance()
	healthBar.scale = Vector2(.6,.6);
	healthBar.position = Vector2(0,190);
	add_child(healthBar)
	updateDisplay()
	
func hasProperty(prop:String):
	var negate = false
	var ret
	if prop[0] == "-":
		negate = true
		prop = prop.substr(1)
	if prop == 'any' or prop == "exists":
		ret =true
	elif prop == self.title:
		ret = true
	elif status.has(prop):
		ret = true
	else:
		ret = false
	if negate:
		return not ret
	else:
		return ret
func takeDamage(amount,types, attacker):
	#set enemies on fire, if they are flammable and in water
	if "fire" in types and status.has("flammable") and not Utility.interpretTerrain("water") == tile.terrain:
		status["flaming"] = true
	#put out fire
	if ("water" in types or "ice" in types) and status.has("flaming"):
		status.erase("flaming")
	#thorns
	if (status.has("thorns") and status.thorns is int and attacker !=null):
		attacker.takeDamage(status.thorns, ["thorns"],null)
	for atype in types:
		if status.has("immune:"+atype):
			amount = 0
			break
	for atype in types:
		if status.has("resistant:"+atype):
			amount = amount/2.0
			break
	for atype in types:
		if status.has("vulnerable:"+atype):
			amount = amount*1.5
	if amount > 0:
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
	if status.has("lifelink"):
		for unit in get_parent().units:
			if unit != null and unit.title == self.title:
				unit.health = self.health
				unit.updateDisplay()
				
	self.Damaged(amount,types,attacker)
	if health <= 0:
		
		get_parent().map.cardController.triggerAll("death",[self,types,attacker])
		if status.has("lifelink"):
			for unit in get_parent().units:
				if unit.title == self.title and unit != self:
					unit.die(null)
		die(attacker)
		return [amount,"kill"]
	else:
		updateDisplay()
	get_parent().map.cardController.triggerAll("damageDealt",[self,amount,types,attacker])
	return [amount]
func startOfTurn():
	if status.has("flaming") and not status.has("fireproof"):
		takeDamage(floor(health/2),["fire"],null)
	block = 0;
func endOfTurn():
	for key in status:
		if status[key] is int:
			status[key] = status[key]-1
			if status[key] <= 0:
				status.erase(key)
		
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
	if self.difficulty > 0:
		get_parent().cardController.Action("create",["Common Loot","Discard"])
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
	if get_parent().units.find(self)==-1:
		assert(false, "failure to die properly" )
	get_parent().units.erase(self)
	yield(get_tree().create_timer(1),"timeout")
	queue_free()
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
