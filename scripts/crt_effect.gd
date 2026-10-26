extends Node2D

## CRT Effect Disabled
## Viewport.new() is abstract in Godot 4 - removed to fix breakage
## Game now renders normally without CRT overlay

func _ready() -> void:
	# CRT effect disabled - game renders normally
	# Viewport creation removed as Viewport is abstract in Godot 4
	pass

func _process(delta: float) -> void:
	# CRT effect disabled
	pass
