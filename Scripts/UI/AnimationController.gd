extends "res://Scripts/Controller.gd"
var animationtemplate = preload("res://Images/attackanimations/Animations.tscn")
var longshortgap
var baseanimspeed = .7
var animspeed


func Load(parent):
	animspeed = baseanimspeed/(.01 + global.animationspeed)
	cardController = parent.cardController;
	enemyController = parent.enemyController;
	animationController = self;
	map = parent.map;
	longshortgap = sqrt(map.minSqDist)*1.5;
	var list = global.get_signal_connection_list("animspeedchanged")
	var connected = false
	for dict in list:
		print(dict)
		print("\n")
		if dict.target ==self:
			connected = true
			break
	if !connected:
		global.connect("animspeedchanged",self,"on_animation_speed_change")
func on_animation_speed_change(value):
	animspeed = baseanimspeed/(.01 + value)
	
func Damage(types, attacker, defender):
	var dist = (attacker.position - defender.position).length();
	for type in types:
		type = type.capitalize()
		var anim = ""
		if type in [
			"Bite",
			"Fire",
			"Fungal",
			"Kinetic",
			"Light",
			"Moss",
			"Piercing",
			"Shadow",
			"Slash",
			"Stab",
			"Storm",
			"Ritual",
			"Beam"
		]:
			anim = type
		elif type in [
			"Crush"
			
		]:
			if dist < longshortgap:
				anim = type
			else:
				anim = type+"Long"
		elif type == "Wind":
			anim= "Storm"
		if anim == "":
			print("missing animation for damagetype: " +type)
			continue
		
		var player = animationtemplate.instance()
		var disp  = defender.position -attacker.position
		if disp.x ==0:
			disp = Vector2(.001,disp.y)
		var angle
		if disp.x<0:
			player.scale =  Vector2(-dist/1000,dist/1000)/1.414
			angle = PI/4+atan(disp.y/disp.x)
		else:
			player.scale = Vector2(dist/1000,dist/1000)/1.414
			angle = -PI/2+PI/8 + atan(disp.y/disp.x)
		player.rotation = angle
		player.position=attacker.position
		self.add_child(player)
		player.Play(anim,animspeed);
	
	
