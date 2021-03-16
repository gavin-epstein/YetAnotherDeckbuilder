extends AudioStreamPlayer
const block1 = preload("res://Sounds/Block3.wav")
const crush1 = preload("res://Sounds/Crush1.wav")
const slash1 = preload("res://Sounds/Slash1.wav")
const fire1 = preload("res://Sounds/fire.wav")
const default  = preload("res://Sounds/defaultAttack.wav")
const sounds ={
	"block":[block1],
	"crush":[crush1],
	"slash":[slash1],
	"fire":[fire1],
	"defaultAttack":[default]
}

func playsound(sound):
	if sound is String:
		sound = sounds.get(sound)
		if sound==null:
			return false
		sound = Utility.choice(sound)
	if sound == null:
		return false
	self.stream = sound
	self.playing = true
	return true
