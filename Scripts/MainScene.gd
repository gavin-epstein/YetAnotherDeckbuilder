extends Node2D
onready var enemyController = $Center/MapLayer/EnemyController
onready var map = $Center/MapLayer/Map/MeshInstance2D
onready var cardController = $CardController
onready var animationController = $Center/Animations/AnimationController
const SAVE_NAME = "user://savefile.json"
var loaded = false
var doTutorial=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var file = File.new()
	if file.file_exists(SAVE_NAME):
		loadFromSave()
	else:
		yield($LoadingBar,"startload")
		loadAll()
	
func loadAll():
	if doTutorial:
		enemyController.maxdifficulty = 0
		map = $Center/MapLayer/Tutorial/MeshInstance2D
	else:
		$Center/MapLayer/Tutorial/MeshInstance2D.queue_free()
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
	step = animationController.Load(self)
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	print("done")
	$LoadingBar.queue_free()
	cardController.updateDisplay()
	loaded= true
	if doTutorial:
		$Center/MapLayer/Tutorial/MeshInstance2D.tutorial()
func save():
	var save = {
		"map":map.save(),
		"enemyController":enemyController.save(),
		"cardController":cardController.save(),
	}
	print("saving")
	var file = File.new()
	file.open(SAVE_NAME, File.WRITE)
	file.store_string(to_json(save))
	file.close()
func loadFromSave():
	$Center/MapLayer/Tutorial/MeshInstance2D.queue_free()
	$LoadingBar.startloading()
	var save
	var file = File.new()
	if file.file_exists(SAVE_NAME):
		file.open(SAVE_NAME, File.READ)
		if !file.is_open():
			print("Failed to open "+ SAVE_NAME)
			return 
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			save = data
			var step
			step = map.loadFromSave(save.map, self)
			if step is GDScriptFunctionState:
				yield(step,"completed")
			step = enemyController.loadFromSave(save.enemyController, self)
			if step is GDScriptFunctionState:
				yield(step,"completed")
			step = cardController.loadFromSave(save.cardController, self)
			if step is GDScriptFunctionState:
				yield(step,"completed")
			step = animationController.Load(self)
			if step is GDScriptFunctionState:
				yield(step,"completed")
			$LoadingBar.queue_free()
			cardController.updateDisplay()
			loaded= true
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")
func deletesave():
	var file = File.new()
	if file.file_exists(SAVE_NAME):
		var dir = Directory.new()
		dir.remove(SAVE_NAME)




func _ResignButton(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.



