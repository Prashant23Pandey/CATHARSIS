extends Node2D

@export var enable_crt: bool = true
@export var fisheye_strength: float = 0.3
@export var scanline_intensity: float = 0.3
@export var vignette_intensity: float = 0.3
@export var noise_intensity: float = 0.0

func _ready() -> void:
    set_process(true)

func _process(delta: float) -> void:
    pass
