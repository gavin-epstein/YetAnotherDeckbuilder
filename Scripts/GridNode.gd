extends Node2D

class_name GridNode
const speed = 80
var neighs = []
var terrain:int
var obstruction: bool
var nearCache = {}
var occupants = []
var uvCoords: Vector2
var meshIndex
var destination:Vector2
var dist
var highlighted = false
# -1 unclaimed. 0 wall
var region = -1

var sentinel = false



func _process(delta: float) -> void:
	if get_parent().physics_on and not sentinel:
		#if out of bounds self destruct
		if abs(position.y) > Map.height or abs(position.x) > Map.width:
			self.sentinel = true
			get_parent().destroyNodeAndSpawn(self)
		#move toward destination
		if (position - destination).length_squared() > 4:
			position = position.linear_interpolate(destination, min(1,delta))
		#springyness
		for neigh in neighs:
			if true:
				var dir:Vector2 = neigh.position - self.position
				var length = dir.length_squared()
				if length < Map.minSqDist:
					destination -= (delta * speed* dir.normalized() * Map.minSqDist/max(length,.1))
				elif length > Map.maxSqDist:
					destination += (delta * speed* dir.normalized() * length/Map.maxSqDist)

func added(pos: Vector2)  -> void:
	self.position  = pos;
	self.destination = pos;
	self.neighs = []
func addNeigh(newNode) -> bool:
	for node in neighs:
		if Utility.vecEqual(node.position, newNode.position):
			return false	
	neighs.append(newNode)
	return true
func sortNeighs()->void:
	neighs.sort_custom(self, "angleComp")
func angleComp(A:Node2D,  B:Node2D):
	return position.angle_to_point(A.position) > position.angle_to_point(B.position)
	
func popNode() -> void:
	var updated = []
	for unit in occupants:
		if unit != null:
			unit.queue_free()
	for other in neighs:
		if Utility.vecEqual(other.destination, other.position):
			other.destination = other.position.linear_interpolate(self.position, 1.0/neighs.size())
			updated.append(other)	
	for node in updated:
		#node.popNode()
		pass
func resetDest() -> void:
	self.destination = self.position

func getDirection(dir:Vector2) -> GridNode:
	#TODO
	return self

func hasTerrain(terrains):
	for t in terrains:
		if t is int and t == terrain:
			return true
		elif t is String and t == "any":
			return true
		elif t == Utility.interpretTerrain(terrain):
			return true
	return false
func hasOccupant(occupant):
	if occupant == "any":
		return true
	elif occupant == "empty" and occupants.size() == 0:
		return true
	else:
		for thing in occupants:
			if thing.hasProperty(occupant):
				return true
	return false
func highlight():
	$Highlight.visible = true
	highlighted = true
func dehighlight():
	$Highlight.visible = false
	highlighted = false
