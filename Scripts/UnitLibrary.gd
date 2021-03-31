extends Node2D
var units = {}
var icons = {}
var intenticons={}
var tooltips = {}
var linkages = {}
const unittemplate =preload("res://Unit.tscn")
const linkagetemplate  = preload("res://Units/Linkage.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func Load() -> void:
	var res = loadUnitsFromFile("res://UnitFiles/units01.txt")
	if res is GDScriptFunctionState:
		yield(res, "completed")
	loadIcons("res://Images/StatusIcons/",icons)
	loadIcons("res://Images/IntentIcons/",intenticons)
	loadtooltips("res://Units/tooltips.txt")
	loadLinkagesFromFile("res://UnitFiles/linkages01.txt")
func getRandomEnemy(difficulty, terrain):
	if  difficulty  <10 and (rand_range(0,difficulty) < 1):
		return null
	if difficulty < 1.5:
		return null
	var possible = []
	for unit in units.values():	
		if unit.difficulty <= difficulty and unit.difficulty != -1 and (Utility.interpretTerrain(terrain) in unit.spawnableterrains or "any" in unit.spawnableterrains):
			if unit.difficulty!=0 or rand_range(0,1)<.5:
				possible.append(unit)
	if possible.size() > 0:
		var other  = unittemplate.instance()
		return possible[randi() % possible.size()].deepcopy(other)
	else:
		return null
func loadIcons(dirname, dictname):
	var dir = Directory.new()
	dir.open(dirname)
	dir.list_dir_begin()

	while true:
		var fname = dir.get_next()
		if fname == "":
			break
		elif fname.ends_with(".png.import"):
			fname = fname.substr(0,fname.length()-7)
			dictname[fname.substr(0,fname.length()-4)] = load(dir.get_current_dir()+"/"+fname)

	dir.list_dir_end()

func loadUnitsFromFile(fname):
	var f = File.new()
	f.open(fname, File.READ)
	var code = ""
	while not f.eof_reached():
		var line = f.get_line()
		if line!= "" and line[0] == "#":
			continue
		if line =="" and code != "":
			var unit = unittemplate.instance()
			unit.loadUnitFromString(code)
			self.units[unit.title]= unit
			unit.controller = get_parent()
			code = ""
			
		if not ";" in line and line!="":
			line = line+";"
		code+=line
func loadLinkagesFromFile(fname):
	var f = File.new()
	f.open(fname, File.READ)
	var code = ""
	while not f.eof_reached():
		var line = f.get_line()
		if line!= "" and line[0] == "#":
			continue
		if line =="" and code != "":
			var unit = linkagetemplate.instance()
			unit.loadFromString(code)
			self.linkages[unit.title]= unit
			code = ""
			
		if not ";" in line and line!="":
			line = line+";"
		code+=line
func loadtooltips(fname):
	var f = File.new()
	f.open(fname, File.READ)
	while not f.eof_reached():
		var line = f.get_line()
		if line.find(":") != -1:
			line = line.split(":")
			tooltips[line[0]] = Utility.join(":",Array(line).slice(1, line.size()-1))
		
		
func getUnitByName(name):
	var other  = unittemplate.instance()
	return units[name].deepcopy(other)
func getLinkageByName(lname):
	var other  = linkagetemplate.instance()
	return linkages[lname].deepcopy(other)
