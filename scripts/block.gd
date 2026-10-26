extends StaticBody2D
## Block — used for both dark world walls and lit world platforms.
## World type is set via scene name prefix.

const WORLD_LIT := "world_lit"
const WORLD_DARK := "world_dark"

@onready var _collision: CollisionShape2D = $Collision
@onready var _visual: Polygon2D = $Visual
@onready var _occluder: LightOccluder2D = $Occluder
@onready var _is_lit: bool = false

func _ready() -> void:
	## Determine world type from scene name
	var name = get_name()
	if name.begins_with("BlockLit") or "Lit" in name:
		_is_lit = true
		add_to_group(WORLD_LIT)
	elif name.begins_with("Block") or not "Lit" in name:
		add_to_group(WORLD_DARK)
	
	## Default state: occluder hidden (lit world platforms)
	if _occluder:
		_occluder.visible = not _is_lit

func set_world_inverted(inverted: bool) -> void:
	## Called by player to toggle world state
	if inverted:
		## Inverted: lit blocks become solid, dark blocks become passable
		if _is_lit and _occluder:
			_occluder.visible = true
			_collision.disabled = false
	else:
		## Normal: lit blocks hidden, dark blocks solid
		if _is_lit and _occluder:
			_occluder.visible = false
			_collision.disabled = true

func _process(delta: float) -> void:
	pass
