extends Node2D

class_name GridNode
var neighs = []
var terrain:String
var obstruction: bool
var nearCache = {}
var occupants = []
var uvCoords: Vector2
var meshIndex
var destination:Vector2
# -1 unclaimed. 0 wall
var region = -1
var physics_on


func _process(delta: float) -> void:
	if (position - destination).length_squared() > 4:
		position = position.linear_interpolate(destination, delta)
	if physics_on:
		for neigh in neighs:
			var dir:Vector2 = neigh.position - self.position
			if dir.length_squared() < Map.minSqDist:
				destination -= (delta * 10* dir.normalized())
			elif dir.length_squared() > Map.maxSqDist:
				destination += (delta * 10* dir.normalized())

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
	for other in neighs:
		if Utility.vecEqual(other.destination, other.position):
			other.destination = other.position.linear_interpolate(self.position, 1.0/neighs.size())
			updated.append(other)	
	for node in updated:
		#node.popNode()
		pass
func resetDest() -> void:
	self.destination = self.position
