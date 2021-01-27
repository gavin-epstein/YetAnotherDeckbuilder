extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadAll()
	
func loadAll():
	var screen_size = OS.get_screen_size()
	OS.set_window_size(screen_size)
	var step = $EnemyController.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	step = $Map/MeshInstance2D.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("Map load 1")
	step = $CardController.Load()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("Card load 1")
	step = $Map/MeshInstance2D.Load2()
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("done")
