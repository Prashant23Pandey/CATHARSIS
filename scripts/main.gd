extends Node2D
## Sequence 1 director.
##
## MILESTONE 1 SCOPE: keep the opening playable end-to-end. If the player falls
## into the void between platforms they are returned to the start instead of
## falling forever.

@onready var player: Player = $Player
@onready var spawn: Marker2D = $Spawn

func _ready() -> void:
	get_window().title = "CATHARSIS"
	$VoidZone.body_entered.connect(_on_void_entered)


func _on_void_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).respawn(spawn.global_position)
