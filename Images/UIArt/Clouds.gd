extends MeshInstance2D
const randwidth = 15
const width = 1920
const height = 1080
const vertcount = 20000
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	
func generate()-> void:
	var verts = PoolVector2Array()
	var uvs = PoolVector2Array()
	var indices
	var normals = PoolVector3Array()
	for i in range(vertcount-4):
		var pos = Vector2(rand_range(0,width),rand_range(0,height))
		verts.append(pos)
		uvs.append(pos)
		normals.append(Vector3(0,0,1))
	#Corners
	for x in [0,width]:
		for y in  [0, height]:
			var pos = Vector2(x,y)
			verts.append(pos)
			uvs.append(pos)
			normals.append(Vector3(0,0,1))
			
		
	indices =  Geometry.triangulate_delaunay_2d(verts)	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices
	mesh = ArrayMesh.new()
		# Create mesh surface from mesh array.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
#	var rands = PoolRealArray()
#	for i in range(12*randwidth):
#		rands.append(rand_range(0,1))
#	material.set_shader_param("rands",rands)
#


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
