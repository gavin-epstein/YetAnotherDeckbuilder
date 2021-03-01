extends Node2D
onready var enemyController = $Center/MapLayer/EnemyController
onready var map = $Center/MapLayer/Map/MeshInstance2D
onready var cardController = $CardController

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadAll()
	
func loadAll():
	var screen_size = OS.get_screen_size()
	OS.set_window_size(screen_size)
	var step = enemyController.Load(self)
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	step = map.Load(self)
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("Map load 1")
	step = cardController.Load(self)
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("Card load 1")
	step = map.Load2()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("done")
