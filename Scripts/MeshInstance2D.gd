extends MeshInstance2D
class_name Map

const maxFailedAttempts = 150
const width = 800 #was 960
const height = 475 #was 400
const radius =1.5*max(width, height)
#0 = cicrumcenter, 1 = centroid
const CCinter = .33
const minSqDist = 4000 *5
const maxSqDist = minSqDist*1.2
signal mapGenerated
signal nodeSelected
var highlightTemplate = preload("res://Units/Highlight.tscn")
var gridNodeTemplate = preload("res://Scripts/GridNode.gd");
var nodes = []
var verts = PoolVector2Array()
var uvs = PoolVector2Array()
var indices = PoolIntArray()
var normals = PoolVector3Array()
var Vverts
var Vindices
var Vuvs
var Vnormals
var lastStep
var centerCache = {}
var pausetime = 0.0
var acceptinput = false
var cardController
var enemyController
var sentinels=[]
var physics_on  = false
var voidNode
var selectableNodes = []
var selectedNode
const sentinelrowsep = 160

func Load(parent):
	randomize()
	
	cardController = parent.cardController
	enemyController = parent.enemyController
	var step = generate()
	if step is GDScriptFunctionState:
		step = yield(step, "completed")
	

func _process(delta: float) -> void:
	if pausetime > .1:
		pausetime = 0
		triangulate()
	else:
		pausetime += delta

	# Assign arrays to mesh array.
		
func generate() -> void:
	
	var failedAttempts = 0
	voidNode = addGridNode(Vector2(0,0),-1, true)
	for x in range(-width, width,sqrt(maxSqDist)):
		var pos = Vector2(x,-height-40)
		var color  = -1
		sentinels.append(addGridNode(pos, color,true))
		pos = Vector2(x,height+40)
		
		sentinels.append(addGridNode(pos, color,true))
		#second row
		pos = Vector2(x,-height-sentinelrowsep)
		addGridNode(pos, color,true)
		pos = Vector2(x,height+sentinelrowsep)
		addGridNode(pos, color,true)
	for y in range(-height, height, sqrt(maxSqDist)):
		var pos = Vector2(-width-40, y)
		var color  = -1
		sentinels.append(addGridNode(pos, color,true))
		pos = Vector2(width+40, y)
		color  = -1
		sentinels.append(addGridNode(pos, color,true))
		#outer row
		pos = Vector2(-width-sentinelrowsep, y)	
		addGridNode(pos, color,true)
		pos = Vector2(width+sentinelrowsep, y)
		addGridNode(pos, color,true)
	#var startTime = OS.get_ticks_msec()
	while failedAttempts < maxFailedAttempts:
		var tooclose = false
		#var pos = Vector2(rand_range(0,radius), 0).rotated(rand_range(0,2*PI))
		var pos = Vector2(rand_range(-width,width), rand_range(-height,height))
		for node in nodes:
				if Utility.sqDistToNode(pos, node) < minSqDist:
					failedAttempts+=1
					tooclose= true
					break
		if not tooclose:
			var color  = getTerrain()
			addGridNode(pos, color)	
			
			
			failedAttempts = 0
			
			yield(get_tree().create_timer(.05), "timeout")
	triangulate()
func Load2():
	var step = doPhysics(2);
	if step is GDScriptFunctionState:
		step = yield(step,"completed")
	acceptinput = true
	enemyController.addPlayerAndVoid()
	emit_signal("mapGenerated")
	
	
func triangulate() -> void:	
	centerCache = {}
	var verts = PoolVector2Array()
	for node in nodes:
		node.neighs = []
		verts.append(node.position)
		
	indices =  Geometry.triangulate_delaunay_2d(verts)	
	for i in range(0, self.indices.size(), 3):
		nodes[indices[i+0]].addNeigh(nodes[indices[i+1]]) && nodes[indices[i+1]].addNeigh(nodes[indices[i+0]])
		nodes[indices[i+1]].addNeigh(nodes[indices[i+2]]) && nodes[indices[i+2]].addNeigh(nodes[indices[i+1]])
		nodes[indices[i+2]].addNeigh(nodes[indices[i+0]]) && nodes[indices[i+0]].addNeigh(nodes[indices[i+2]])
	for node in nodes:
		node.sortNeighs()
	Voronoize()
	renderMesh()
func renderMesh()-> void:
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = Vverts
	arr[Mesh.ARRAY_TEX_UV] = Vuvs
	arr[Mesh.ARRAY_NORMAL] = Vnormals
	arr[Mesh.ARRAY_INDEX] = Vindices
	mesh = ArrayMesh.new()
		# Create mesh surface from mesh array.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
func Voronoize() -> void:
	Vverts = PoolVector2Array()
	Vuvs = PoolVector2Array()
	Vindices = PoolIntArray()
	Vnormals = PoolVector3Array()
	for node in nodes:
		node.meshIndex = Vverts.size()
		Vverts.append(node.position)
		Vuvs.append(node.uvCoords)
		Vnormals.append(Vector3(0,0,1))
	for node in nodes:
		var centers = []
		for i in range( node.neighs.size()):
			var A = node.neighs[i]
			var B = node.neighs[(i+1)%node.neighs.size()]
			var ind = getCenterIndex(A,B,node)
			if ind >=0:
				centers.append(getCenterIndex(A,B,node))
		for i in range(centers.size()):
			Vindices.append(node.meshIndex)
			Vindices.append(centers[i])
			Vindices.append(centers[(i+1)%centers.size()])
func getCenterIndex(A:Node2D,B:Node2D,C:Node2D) -> int:
	var centroid = Utility.getCentroid(A,B,C)
	var key = "%.4f%.4f"%[centroid.x, centroid.y]
	if key in centerCache.keys():
		return centerCache[key]
	else:
		var circumcenter = Utility.getCircumcenter(A,B,C)
		var center = circumcenter.linear_interpolate(centroid,CCinter)
		if (circumcenter-centroid).length_squared() > 5*minSqDist:
			center = centroid
	
		Vverts.append(center)
		Vuvs.append(Vector2(0,0))
		Vnormals.append(Vector3(0,0,1))
		centerCache[key] = Vverts.size()-1
		return centerCache[key]
		

func addGridNode(pos:Vector2, terrain:int, sentinel  = false) -> Node2D:
	var newNode = gridNodeTemplate.new()
	newNode.added(pos) 
	newNode.uvCoords = getTerrainColor(terrain)
	newNode.terrain =  terrain
	add_child(newNode) #this is necessary so physics process gets called on children
	nodes.append(newNode)
	var highlight =  highlightTemplate.instance()
	newNode.add_child(highlight)
	highlight.visible = false
	highlight.name = "Highlight"
	if not sentinel:
		triangulate()
		#make biomes
		var tries =0
		var other = Utility.choice(newNode.neighs)
		while tries < 1 and other.sentinel:
			other = Utility.choice(newNode.neighs)
			tries+=1
		if not other.sentinel:
			newNode.terrain = other.terrain
			newNode.uvCoords = getTerrainColor(other.terrain)
		enemyController.nodeSpawned(newNode)
	else:
		newNode.sentinel = true
	return newNode

func getTerrain() -> int:
	return randi()%Utility.Terrain.size();
func getTerrainColor(terrain:int) -> Vector2:
	if terrain < 0:
		return Vector2(0,0)
	var angle = PI/2 - (PI/18 * (terrain)) -.005
	return Vector2(.5*cos(angle),.5*sin(angle))


func _on_MapArea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if acceptinput:
		if cardController.takeFocus(self):
			if event.is_action_pressed("left_click"):
				var pos = get_global_mouse_position() -  self.get_global_transform().get_origin() 
				if selectableNodes.size() > 0:
					var closest = selectableNodes[0]
					for node in selectableNodes:
						if Utility.sqDistToNode(pos, closest)> Utility.sqDistToNode(pos, node):
							closest = node
					selectedNode = closest
					emit_signal("nodeSelected")
			cardController.releaseFocus(self)
		else:
			var other  = cardController.focus
			if other != null:
				pass
				#print("Focus is on ", cardController.focus.get("name"),": ", other.get("title")," ", other.get_parent().get("name"))
			
func doPhysics(time): 
	print("Physics going")
	cardController.takeFocus(self)
	self.physics_on  = true
	yield(get_tree().create_timer(time), "timeout")
	self.physics_on = false
	cardController.releaseFocus(self)
func getRandomEmptyNode(terrains):
	var possible = []
	for node in nodes:
		if node.hasTerrain(terrains) and node.occupants.size() == 0 and not node.sentinel:
			possible.append(node)
	return possible[randi()%possible.size()]

func destroyNodeAndSpawn(node):
	node.popNode()
	nodes.erase(node)
	var newpos = rand_range(.95,.8)* (sentinels[randi()%sentinels.size()].position)
	addGridNode(newpos, getTerrain())	
	triangulate()
	doPhysics(3)
	
	
func getTiles(tile,dist:int,property,terrains):
	if tile == null:
		return []
	var possible
	selectableNodes  = []
	if dist > 20:
		possible = nodes
	else:
		possible = []
		for node in nodes:
			node.dist = null #god i love null as a special value its probly bad
		#bfs
		tile.dist = 0
		var q = [tile]
		while q.size()>0:
			var next = q.pop_front()
			#multitile unit targeting
			if next.occupants.size()>0:
				possible.append(next.occupants[0].head.tile)
			else:
				possible.append(next)
			if next.dist < dist:
				for neigh in next.neighs:
					if not (neigh.sentinel and neigh.occupants.size() ==0) and neigh.dist  == null:
						neigh.dist = next.dist+1
						q.append(neigh)
	for node in possible:
		if node.hasTerrain(terrains) and node.hasOccupant(property) and not (node.sentinel and node.occupants.size() == 0):
			node.highlight()
			selectableNodes.append(node)
	if selectableNodes.size() ==0:
		return null
		#assert(false, "Implement this case")
	
	
func select(tile,dist,property,terrains, message):
	getTiles(tile,dist,property,terrains)
	if selectableNodes.size()==0:
		return null
	elif selectableNodes.size()==1:
		selectableNodes[0].dehighlight()
		return selectableNodes[0]
	$Message/Message/Message.bbcode_text = "[center]"+message+"[/center]"
	$Message/Message.visible = true
	yield(self,"nodeSelected")
	$Message/Message.visible = false
	for node in selectableNodes:
		node.dehighlight()
	return selectedNode
func selectRandom(tile,dist,property,terrains):
	getTiles(tile,dist,property,terrains)
	for node in selectableNodes:
		node.dehighlight()
	if selectableNodes.size()==0:
		return null
	return selectableNodes[randi()%selectableNodes.size()]
	
func selectAll(tile,dist,property,terrains):
	getTiles(tile,dist,property,terrains)
	for node in selectableNodes:
		node.dehighlight()
	return selectableNodes
func getTileInDirection(tile,dir):
	dir = tile.position + dir*300
	var closest = tile.neighs[0]
	var closedist = Utility.sqDistToNode(dir, tile)
	for node in tile.neighs:
		var dist = Utility.sqDistToNode(dir,node)
		if dist < closedist:
			closest = node
			closedist = dist
	return closest	

func getTileClosestTo(tile, pos):
	return getTileClosestToSet(tile,[pos])
func getTileClosestToSet(start, dests):
	
	var closest = start.neighs[0]
	var closedist = minDistToPositions(closest, dests)
	for node in start.neighs:
		var dist = minDistToPositions(node, dests)
		if dist < closedist:
			closest = node
			closedist = dist
	return closest	
func minDistToPositions(tile,positions):
	var closedist = Utility.sqDistToNode(positions[0].position, tile)
	for pos in positions:
		var dist = Utility.sqDistToNode(pos.position,tile)
		if dist < closedist:
			closedist = dist
	return closedist
	
func save()->Dictionary:
	var savenodes = []
	for node in nodes:
		savenodes.append(node.save())
	var savesentinels = []
	for node in sentinels:
		savesentinels.append(nodes.find(node))
	return{
		"nodes":savenodes,
		"sentinels":savesentinels,
		"voidNode":nodes.find(voidNode)
	}
func loadFromSave(save:Dictionary, parent):
	cardController = parent.cardController
	enemyController = parent.enemyController
	nodes = []
	for savenode in save.nodes:
		var node = gridNodeTemplate.new()
		node.loadFromSave(savenode)
		nodes.append(node)
		add_child(node)
		var highlight =  highlightTemplate.instance()
		node.add_child(highlight)
		self.add_child(highlight)
		highlight.visible = false
		highlight.name = "Highlight"
	sentinels =[]
	for index in save.sentinels:
		sentinels.append(nodes[int(index)])
	voidNode = nodes[int(save.voidNode)]
	
	triangulate()
	acceptinput = true
