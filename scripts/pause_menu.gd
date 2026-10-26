class_name PauseMenu
extends CanvasLayer

var overlay = null
var dim = null
var title = null
var resume_label = null
var save_label = null
var load_label = null
var main_label = null
var confirmation_label = null
var _timer = 0.0

func _ready():
	overlay = Control.new()
	overlay.visible = false
	add_child(overlay)

	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	add_child(dim)

	title = Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	title.add_theme_font_size_override("font_size", 48)
	add_child(title)

	resume_label = Label.new()
	resume_label.text = "RESUME"
	resume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resume_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	resume_label.add_theme_font_size_override("font_size", 32)
	add_child(resume_label)

	save_label = Label.new()
	save_label.text = "SAVE GAME"
	save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	save_label.add_theme_font_size_override("font_size", 32)
	add_child(save_label)

	load_label = Label.new()
	load_label.text = "LOAD GAME"
	load_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	load_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	load_label.add_theme_font_size_override("font_size", 32)
	add_child(load_label)

	main_label = Label.new()
	main_label.text = "MAIN MENU"
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main_label.add_theme_font_size_override("font_size", 32)
	add_child(main_label)

	confirmation_label = Label.new()
	confirmation_label.text = ""
	confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	confirmation_label.add_theme_font_size_override("font_size", 20)
	confirmation_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	add_child(confirmation_label)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			_timer = 1.5
			confirmation_label.text = "PAUSED"

func _process(delta):
	_timer = max(0.0, _timer - delta)
	if title != null:
		title.visible = _timer > 0.0
	if confirmation_label != null:
		confirmation_label.visible = _timer > 0.0 and _timer < 1.0
