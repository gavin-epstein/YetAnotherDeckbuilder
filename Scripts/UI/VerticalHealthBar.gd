extends Node2D
var unit
export var totalsize = 600
export var hasbossicon=false
var width = 60


func updateDisplay():
	if unit==null:
		return
	$Back.rect_size= Vector2(width,totalsize)
	var healthheight = int((totalsize*unit.health)/unit.maxHealth)
	for _thing in [$front1,$front2]:
		_thing.rect_size= Vector2(width, healthheight)
		_thing.rect_position = Vector2(0,totalsize-healthheight)
	if totalsize-healthheight<40:
		$maxhealthlabel.visible=false
	else:
		$maxhealthlabel.visible=true
		$maxhealthlabel.bbcode_text = "[center]"+str(unit.maxHealth)+"[/center]"
	$currenthealthlabel.rect_position = Vector2(0,totalsize-healthheight)
	$currenthealthlabel.bbcode_text = "[center]"+str(unit.health)+"[/center]"
	if self.hasbossicon:
		var threshhold = 150
		var iconheight = int((totalsize*threshhold)/unit.maxHealth)
		$bossIcon1.position = Vector2(0,totalsize - iconheight)
