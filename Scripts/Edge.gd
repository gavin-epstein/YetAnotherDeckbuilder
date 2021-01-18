extends Node2D
class_name Edge
var p0: Vector2
var p1: Vector2
var n0
var n1
var sqLength: float
func calcLength() -> void:
	sqLength =  (p0.x -p1.x)*(p0.x -p1.x)+(p0.y -p1.y)*(p0.y -p1.y)
	
func _init(n0,n1):
	self.p0 = n0.position
	self.p1 = n1.position
	self.n0 = n0
	self.n1 = n1
	self.z_index = 2
	calcLength()
	
func _draw()-> void:
	#pass
	draw_line(p0,p1, Color(.5,0,1))

	
