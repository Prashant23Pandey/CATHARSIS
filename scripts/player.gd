class_name Player
extends CharacterBody2D
## The knight. Running, jumping and the torch.
##
## MILESTONE 1 SCOPE: movement, jumping, torch lighting. No combat yet —
## `AttackArea` exists so the node separation is already correct, but it stays
## disabled until Milestone 3.
##
## The body is an AnimatedSprite2D playing the 4-frame "idle" loop cut from
## `assets/idle.png` (a 2x2 sheet of 32x32 frames, all four different). It is
## scaled and offset so the drawn character exactly fills the 40x56 collision
## box, feet on the collider's bottom edge, and is mirrored with `facing` so the
## torch it holds stays on the side the TorchLight swings to.
##
## The torch is two PointLight2D children:
##   TorchLight - warm, offset in the facing direction, casts shadows.
##   GlowLight  - dim, centred, keeps the immediate area readable.

const SPEED := 240.0
const ACCEL := 2400.0
const FRICTION := 2800.0
const AIR_ACCEL := 1500.0
const JUMP_VELOCITY := -560.0
const GRAVITY := 1500.0
const MAX_FALL := 900.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER_TIME := 0.12
const JUMP_CUT := 0.45
const TORCH_REACH := 34.0
const TORCH_BASE_ENERGY := 1.35
const GLOW_BASE_ENERGY := 0.30
const DASH_DURATION := 0.12
const DASH_SPEED := 600.0
const DASH_COOLDOWN := 0.5
const INVERT_DEBOUNCE := 0.2

@onready var _body: AnimatedSprite2D = $Body
@onready var _torch: PointLight2D = $TorchLight
@onready var _glow: PointLight2D = $GlowLight

var facing: int = 1

var _body_base_scale: Vector2 = Vector2.ONE

var _coyote: float = 0.0
var _jump_buffer: float = 0.0
var _flicker_t: float = 0.0
var _crouching: bool = false

var _dashing: bool = false
var _dash_timer: float = 0.0
var _dash_cooldown: float = 0.0

var _inverted: bool = false
var _invert_timer: float = 0.0


func _ready() -> void:
	add_to_group("player")
	_flicker_t = randf() * 10.0
	_body_base_scale = _body.scale
	_body.play("idle")


func _physics_process(delta: float) -> void:
	## ---- Dash timer logic (active when dashing) ----
	if _dashing:
		_dash_timer += delta
		if _dash_timer >= DASH_DURATION:
			_dashing = false
			_dash_timer = 0.0
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * 2.0 * delta)
		else:
			velocity.x = DASH_SPEED * facing
		## During dash: skip normal input processing
		## Fall through will handle normal movement since _dashing is set
	elif _dash_cooldown > 0.0:
		_dash_cooldown -= delta
		if _dash_cooldown <= 0.0:
			_dash_cooldown = 0.0
	else:
		## ---- Normal movement handling ----
		var dir: float = Input.get_axis("move_left", "move_right")
		
		_crouching = Input.is_action_pressed("down") and is_on_floor()
		_body.scale.y = lerpf(_body.scale.y, _body_base_scale.y * (0.6 if _crouching else 1.0), 12.0 * delta)
		var target_speed: float = SPEED * (0.4 if _crouching else 1.0)
		
		if absf(dir) > 0.1 and not _dashing:
			facing = 1 if dir > 0.0 else -1
			_body.flip_h = facing < 0
			var accel: float = ACCEL if is_on_floor() else AIR_ACCEL
			velocity.x = move_toward(velocity.x, dir * target_speed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	
	## ---- gravity ----
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	
	## ---- jump: coyote time + input buffering ----
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote = maxf(_coyote - delta, 0.0)
	
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = JUMP_BUFFER_TIME
	else:
		_jump_buffer = maxf(_jump_buffer - delta, 0.0)
	
	if _jump_buffer > 0.0 and _coyote > 0.0 and not _crouching:
		velocity.y = JUMP_VELOCITY
		_jump_buffer = 0.0
		_coyote = 0.0
	
	## Short tap = short hop, held = full jump.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT
	
	## ---- dash input check ----
	var dash_pressed = Input.is_action_pressed("dash")
	if dash_pressed and _dash_cooldown <= 0.0 and not _dashing:
		_dashing = true
		_dash_cooldown = DASH_COOLDOWN
		if is_on_floor():
			velocity.x = DASH_SPEED * facing
		else:
			velocity.x = DASH_SPEED * facing
	
	move_and_slide()
	
	## ---- world invert input ----
	var invert_pressed = Input.is_action_pressed("world_invert")
	if invert_pressed and _invert_timer <= 0.0:
		_invert_timer = INVERT_DEBOUNCE
		_toggle_world()
	
	## ---- dash timer update (after move) ----
	if _dashing:
		_dash_timer += delta
		if _dash_timer >= DASH_DURATION:
			_dashing = false
			_dash_timer = 0.0
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * 2.0 * delta)
		elif _dash_cooldown > 0.0:
			_dash_cooldown -= delta
			if _dash_cooldown <= 0.0:
				_dash_cooldown = 0.0
	
	## --- torch ---
	_torch.position.x = lerpf(_torch.position.x, TORCH_REACH * facing, 10.0 * delta)


func _toggle_world() -> void:
	_inverted = not _inverted
	_apply_world_state(_inverted)

func _apply_world_state(inverted: bool) -> void:
	_inverted = inverted
	var lit_nodes = get_tree().get_nodes_in_group("world_lit")
	for n in lit_nodes:
		if n.is_class_name("CollisionShape2D"):
			if inverted:
				n.collision_layer = 1
				n.collision_mask = 2
			else:
				n.collision_layer = 0
				n.collision_mask = 0
	
	var dark_nodes = get_tree().get_nodes_in_group("world_dark")
	for n in dark_nodes:
		if n.is_valid() and n is CollisionShape2D:
			if inverted:
				n.collision_layer = 0
				n.collision_mask = 0
			else:
				n.collision_layer = 1
				n.collision_mask = 1
	
func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	var cam: Camera2D = get_node_or_null("Camera2D") as Camera2D
	if cam != null:
		cam.reset_smoothing()
