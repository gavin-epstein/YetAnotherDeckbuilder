extends Node2D
const tstep = .01
var facing=0
var type
var cardtype
var gridx
var gridy
var prev
var cost = 0
#const a = preload("res://Images/Puzzles/EnchantersPipes/bent.png")
func _ready() -> void:
	set_process(false)
	

func scramble():
	self.facing = Utility.choice([0,90,180,270])
	imagerot()
func face(angle:int):
	self.facing = angle
	imagerot()
	
	
func spin()-> void:
	self.facing = (self.facing+90)%360
	var totaltime = 0
	while totaltime < .1:
		imagerot(self.facing-90 + 10*totaltime*90)
		#$image.rotate( tstep/.1 * PI/2)
		yield(get_tree().create_timer(tstep),"timeout")
		totaltime+=tstep
	imagerot()
	
func _on_ColorRect_gui_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("left_click"):
		
		spin()
func setType(type:String, image):
	self.type = type
	$image.texture = image
	$image2.texture = image
	if type in ["inputplatform", "outputplatform"]:
		$typeicon.visible = true
		
func setCost(cost):
	if self.type in  ["inputplatform", "outputplatform", "doublediagonal"]:
		return
	self.cost = cost
	if cost !=0:
		$energyIcon.visible = true
		var pm = "+"
		if cost < 0:
			pm = ""
		$energyIcon/Text.bbcode_text = "[center]"+pm+str(cost)+"[/center]"
func connects(fromdirection:int):
	if self.type == "4way":
		return true
	if self.type in ["1way", "inputplatform", "outputplatform"]:
		return fromdirection == facing
	if self.type in ["bent", "doublediagonal"]:
		if fromdirection in [aa(facing, 270), aa(facing, 180)]:
			return false
		return true
	if self.type =="3way":
		if fromdirection == aa(facing, 180):
			return false
		return true
	if self.type == "straight":
		if fromdirection in [aa(facing, 270), aa(facing, 90)]:
			return false
		return true
	return false
func reset():
	prev = null
	modulate = Color(1,1,1)
#add angle
static func aa(a,b) -> int:
	return (a+b)%360

func imagerot(angle = null):
	
	if angle == null:
		$image.material.set_shader_param("angle",self.facing*PI/180)
		$image2.rotation_degrees = self.facing
	else:
		$image.material.set_shader_param("angle",angle*PI/180)
		$image2.rotation_degrees = angle


func setRect(topleft, topright, bottomleft, bottomright):
		var top = Vector2(min(topleft.x, bottomleft.x),min(topleft.y, topright.y))
		var bot = Vector2(min(topright.x, bottomright.x),min(bottomleft.y, bottomright.y))
		var center = (top+bot)/2
		self.position = center
		var sc = 0.0;
		for thing in [topleft, topright, bottomleft, bottomright]:
			var val = abs(center.x - thing.x)
			if val > sc:
				sc = val
			val = abs(center.y - thing.y)
			if val > sc:
				sc = val
		sc=sc/150
		self.scale =Vector2(sc, sc)
		$image.material.set_shader_param("topright",(topright -top)/sc)
		$image.material.set_shader_param("topleft",(topleft - top)/sc)
		$image.material.set_shader_param("bottomleft",(bottomleft - top)/sc)
		$image.material.set_shader_param("bottomright",(bottomright-top)/sc)
		var sum = Vector2(0,0)
		var corners = [topleft, topright, bottomleft, bottomright]
		for thing in corners:
			sum += (thing-top)/sc
		$typeicon.position = sum/4-Vector2(150,150)
		$energyIcon.position = sum/4-Vector2(150,150)


func _on_image_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_parent().get_parent().tileclicked(self)
