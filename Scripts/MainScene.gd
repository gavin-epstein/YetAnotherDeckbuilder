extends Node2D
onready var enemyController = $Center/MapLayer/EnemyController
onready var map = $Center/MapLayer/Map/MeshInstance2D
onready var cardController = $CardController
const SAVE_NAME = "res://Saves/savefile.json"
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
func save():
	var save = {
		"map":map.save(),
		"enemyController":enemyController.save(),
		"cardController":cardController.save(),
	}
	var file = File.new()
	file.open(SAVE_NAME, File.WRITE)
	file.store_string(to_json(save))
	file.close()
func loadFromSave():
	var save
	var file = File.new()
	if file.file_exists(SAVE_NAME):
		file.open(SAVE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			save = data
			map.loadFromSave(save.map, self)
			enemyController.loadFromSave(save.enemyController, self)
			cardController.loadFromSave(save.cardController, self)
			
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")





func _ResignButton(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
