extends Node2D


var title
var text

func createByText(title, text, image=null):
	self.title = title
	self.text  = text
	if image!=null:
		$Sprite.texture = image
	$Title.bbcode_text = title.strip_edges()
	$Body.bbcode_text = text.strip_edges()
	$BigImage.visible = false
func createByImage(title, imagename):
	self.title = title
	self.text  = ""
	$Title.bbcode_text = title.strip_edges()
	$BigImage.texture  = load(imagename)
	$Body.visible = false
	$Sprite.visible = false
	$ColorRect2.visible = false



func setText(intext):
	self.text  =intext
	$Body.bbcode_text = intext.strip_edges()


func _on_Body_meta_clicked(meta) -> void:
	get_parent().get_parent().get_parent().displayPage(meta)
