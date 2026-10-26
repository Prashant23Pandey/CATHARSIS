class_name MainMenu
extends Control

var _selected = 0
var _option_texts = ["NEW GAME", "CONTINUE", "QUIT"]
var _options = []
var _timer = 0.0
var confirmation_label = null

func _ready():
	## Background
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.03, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	## Title
	var title = Label.new()
	title.text = "CATHARSIS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	title.add_theme_font_size_override("font_size", 64)
	title.color = Color(0.93, 0.93, 0.93)
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.offset_min = Vector2(0, 60)
	add_child(title)

	## Subtitle
	var subtitle = Label.new()
	subtitle.text = "— BORN TWICE —"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.color = Color(0.6, 0.6, 0.6)
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	subtitle.offset_min = Vector2(0, 120)
	add_child(subtitle)

	## Options
	for i in range(_option_texts.size()):
		var opt = Label.new()
		opt.text = _option_texts[i]
		opt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		opt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		opt.add_theme_font_size_override("font_size", 32)
		add_child(opt)
		_options.append(opt)

	## Confirmation label
	confirmation_label = Label.new()
	confirmation_label.text = ""
	confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	confirmation_label.add_theme_font_size_override("font_size", 20)
	confirmation_label.color = Color(1.0, 0.8, 0.0)
	confirmation_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation_label.offset_max = Vector2(0, -20)
	add_child(confirmation_label)

	_selected = 0
	_update_selection()

func _process(delta):
	_timer = max(0.0, _timer - delta)
	if confirmation_label != null:
		confirmation_label.visible = _timer > 0.0 and _timer < 1.0

func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		_selected = wrapi(_selected - 1, 0, 2)
		_update_selection()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_down"):
		_selected = wrapi(_selected + 1, 0, 2)
		_update_selection()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_accept"):
		_option_selected(_selected)

func wrapi(value, min_val, max_val):
	var result = min(max(value, min_val), max_val)
	if result > max_val:
		result = min_val
	if result < min_val:
		result = max_val
	return result

func _option_selected(selected):
	if selected == 0:
		confirmation_label.text = "Starting new game..."
		confirmation_label.visible = true
		_timer = 2.0
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	elif selected == 1:
		confirmation_label.text = "Loading game..."
		confirmation_label.visible = true
		_timer = 2.0
	elif selected == 2:
		get_tree().quit()

func _update_selection():
	for i in range(_options.size()):
		if i == _selected:
			_options[i].add_theme_font_size_override("font_size", 36)
			_options[i].add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
		else:
			_options[i].add_theme_font_size_override("font_size", 32)
			_options[i].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
