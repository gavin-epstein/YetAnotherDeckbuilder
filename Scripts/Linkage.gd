extends Node2D
var verticaloffset=0
var ends =[]
var policy="stretch"
var head: Executable
var title
var needstospring
var needstodie

const checkdelay = .2
var time = 0



# Called when the node enters the scene tree for the first time.
func _process(delta:float):
	time+=delta
	#Set self position
	var up = ends[1].position - ends[0].position
	$Image.angle = up.angle + PI/4
	self.position = ends[0].position + .5*up + verticaloffset
	
	
	#Checking spring and deletion
	if time >= checkdelay:
		
		time=0
		var resetdie =true
		for end in ends:
			if end == null:
				if needstodie:
					queue_free()
					return
				else:
					resetdie = false
					needstodie = true
		if resetdie:
			self.z_index = (ends[0].z_index+ ends[1].z_index)/2
			needstodie = false
		if not getTile(ends[0]) in getTile(ends[1]).neighs:
			if needstospring:
				if ends[0].has_method("isUnit") and not ends[1].hasMethod("isUnit"):
					spring(ends[0], ends[1])
				elif ends[1].has_method("isUnit") and not ends[0].hasMethod("isUnit"):
					spring(ends[1], ends[0])
				elif ends[0].has_method("isUnit") and ends[1].hasMethod("isUnit"):
					var disttohead0 = Utility.sqDistToNode(ends[0].position, head)
					var disttohead1 = Utility.sqDistToNode(ends[1].position, head)
					if disttohead0 < disttohead1:
						spring(ends[1], ends[0])
					else:
						spring(ends[0], ends[1])
			else:
				needstospring = true	
		else:
			needstospring = false
func getTile(endpoint):
	if endpoint.get("tile")!=null:
		return endpoint.tile
	else:
		return endpoint
func spring(move, towards):
	var controller = head.controller.enemyController
	var tile = controller.getTileInDirection(getTile(move),towards.position)
	if tile.occupants.size() ==0 and not tile.sentinel:
		controller.move(move, tile)
		needstospring = false
	else:
		pass
		#TODO figure how to spring if blocked
func loadFromString(string):
	var lines = string.split(";")
	for line in lines:
		if line == "" or line == " ":
			continue
		var parsed = Utility.parseCardCode(line)
		if parsed[0] == "image":
			$Image.texture= load(parsed[1][0])
		elif parsed[0] == "policy":
			self.policy = parsed[1][0]
		elif parsed[0] == "title" or parsed[0] =="name":
			self.title = Utility.join(" ",parsed[1])
func deepcopy(other):
	var properties = self.get_property_list()
	for prop in properties:
		var name = prop.name;
		var val = self.get(name);
		if val is Array or val is Dictionary:
			other.set(name,val.duplicate(true))
		elif val == null or not val is Object:
			other.set(name, val);
		else:
			pass
	other.get_node("Image").texture = $Image.texture
func setup(e1,e2,head):
	ends = [e1,e2]
	self.head = head
