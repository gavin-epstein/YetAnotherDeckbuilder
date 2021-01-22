extends Node2D
var units = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadUnitsFromFile("res://UnitFiles/units01.txt")

func getRandomEnemy(difficulty, terrain):
	if (rand_range(0,difficulty) < 1):
		return null
	var possible = []
	for unit in units.values():
		
		if unit.difficulty <= difficulty and unit.difficulty != -1 and (terrain in unit.spawns or "any" in unit.spawns):
			possible.append(unit)
	if possible.size() > 0:
		return possible[randi() % possible.size()].sceneName
	else:
		return null

func loadUnitsFromFile(fname):
	var f = File.new()
	f.open(fname, File.READ)
	var unit = {}
	while not f.eof_reached():
		var line = f.get_line()
		if line != "":
			line = Utility.parseCardCode(line)
			if line[0] =="scene":
				unit.sceneName = line[1][0]
			elif line[0] == "difficulty":
				unit.difficulty = line[1][0]
			elif line[0] == "spawnable":
				unit.spawns = []
				for string in line[1]:
					unit.spawns.append(Utility.interpretTerrain(string) )
			elif line[0] == "name":
				unit.name = line[1][0]
		elif line =="" and unit.size()!=0:
			units[unit.name] = unit
			unit = {}
		
