extends Node
const SETTINGS = "user://settings.json"
var lossImage = preload("res://Images/UIArt/EmptyLantern.png")
var animationspeed = 1.6


signal animspeedchanged(animationspeed)

func saveSettings():
	var save = {
		"sfx_volume": db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))),
		"music_volume":db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))),
		"animation_speed":animationspeed
	}
	var file = File.new()
	file.open(SETTINGS, File.WRITE)
	file.store_string(to_json(save))
	file.close()

func loadSettings():
	print("loading settings")
	var save
	var file = File.new()
	if file.file_exists(SETTINGS):
		file.open(SETTINGS, File.READ)
		if !file.is_open():
			print("Failed to open "+ SETTINGS)
			return 
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			save = data
			if "sfx_volume" in save:
				var bus = AudioServer.get_bus_index("SFX")
				var val =  linear2db(save.sfx_volume)
				AudioServer.set_bus_volume_db(bus, val)
			
			if "music_volume" in save:
				var bus = AudioServer.get_bus_index("Music")
				var val =  linear2db(save.music_volume)
				AudioServer.set_bus_volume_db(bus, val)
		
			if "animation_speed" in save:
				animationspeed = save.animation_speed
				emit_signal("animspeedchanged", animationspeed)

