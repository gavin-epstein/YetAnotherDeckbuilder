extends Node2D
export var difficulty: int
export var health: int
export var status = {}
var spawnableTerrains = {}
var healthBarTemplate = preload("res://HealthBar.tscn")
var healthBar
var tile
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addHealthBar()
func _process(delta: float) -> void:
	if tile != null and (self.position - tile.position).length_squared()>100:
		self.position  += (tile.position - self.position)*delta
	self.z_index = (500+position.y)/10;

func takeTurn():
	pass


func move(direction:Vector2, distance):
	pass

func addHealthBar():
	healthBar  = healthBarTemplate.instance()
	healthBar.scale = Vector2(.65,.65);
	healthBar.position = Vector2(220,220);
	add_child(healthBar)
	healthBar.get_node("Number").bbcode_text = "[center]"+str(health)+"[/center]"
	
