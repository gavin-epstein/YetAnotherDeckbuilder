extends MeshInstance2D
class_name Map
var maxFailedAttempts = 20
const width = 960
const height = 500
const radius =1.5*max(width, height)
#0 = cicrumcenter, 1 = centroid
const CCinter = .33
const minSqDist = 4000
const maxSqDist = 16000
var nodes = []
var verts = PoolVector2Array()
var uvs = PoolVector2Array()
var indices = PoolIntArray()
var normals = PoolVector3Array()
var Vverts
var Vindices
var Vuvs
var Vnormals
var started = false
var done  =false
var lastStep
var centerCache = {}
var pausetime = 0.0
var acceptinput = false
var gridNodeTemplate
var cardController

func _ready() -> void:
	randomize()
	gridNodeTemplate = load("res://Scripts/GridNode.gd");
	cardController = get_node("../../CardController");
func _process(delta: float) -> void:
	
	
	if not lastStep is GDScriptFunctionState:
			if not started:
				print("call to generate")
				started = true
				lastStep = generate()
				
			else:
				done = true
				acceptinput = true
	else:
		
		#print("Vertices:" , verts.size())
			lastStep = lastStep.resume()
			triangulate()
			pausetime = 0
		
	if pausetime > .1:
		pausetime = 0
		triangulate()
	else:
		pausetime += delta
	
	
	
	# Assign arrays to mesh array.
		
func generate() -> void:
	
	var failedAttempts = 0
	var nodeCount = 0
	#var startTime = OS.get_ticks_msec()
	while failedAttempts < maxFailedAttempts:
		var tooclose = false
		var pos = Vector2(rand_range(0,radius), 0).rotated(rand_range(0,2*PI))
		for node in nodes:
				if Utility.sqDistToNode(pos, node) < minSqDist:
					failedAttempts+=1
					tooclose= true
					break
		if not tooclose:
			var color = getRandomColor()
			
			addGridNode(pos, color)	
			nodeCount +=1
			#print("Node %3d in %3.f ms after %2d attempts"%[nodeCount,(OS.get_ticks_msec() - startTime), failedAttempts])
			failedAttempts = 0
			#print('Node at %.3f,%.3f'% [pos.x, pos.y])		
			yield()
	triangulate()
	for node in nodes:
		node.physics_on = true
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
		

func addGridNode(pos:Vector2, uvCoords:Vector2) -> Node2D:
	var newNode = gridNodeTemplate.new()
	newNode.added(pos) 
	newNode.uvCoords = uvCoords
	add_child(newNode)
	nodes.append(newNode)
	return newNode


func getRandomColor() -> Vector2:
	var angle =PI/18 * (randi()%8)-.01
	return Vector2(.5*cos(angle),.5*sin(angle))


func _on_MapArea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if acceptinput:
		if cardController.takeFocus(self):
			if event.is_action("left_click"):
				var pos = get_global_mouse_position() -  self.get_global_transform().get_origin() 
				var closest = nodes[0]
				for node in nodes:
					node.resetDest()
					if Utility.sqDistToNode(pos, closest)> Utility.sqDistToNode(pos, node):
						closest = node
				closest.popNode()
				closest.uvCoords=Vector2(0,0)
				nodes.erase(closest)
				var newpos = Vector2(radius, 0).rotated(rand_range(0,2*PI))
				addGridNode(newpos, getRandomColor())	
				triangulate()
			cardController.releaseFocus(self)
				
