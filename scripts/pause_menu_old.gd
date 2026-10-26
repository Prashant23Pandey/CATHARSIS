class_name PauseMenu
extends CanvasLayer

var overlay = null
var dim = null
var title = null

func _ready():
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	add_child(overlay)

	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)

	title = Label.new()
	title.text = "PAUSED"
	title.set_anchors_and_offsets_preset(Control.PRESET_LEFT)
	title.offset_min = Vector2(0, 40)
	overlay.add_child(title)

func _process(delta):
	pass
