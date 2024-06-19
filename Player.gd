extends CharacterBody2D

@export var GRAVITY = 3500
@export var MAX_SPEED = 450
@export var ACCELERATION = 16000
@export var DECELERATION = 2000
@export var JUMP_STRENGTH = 1450
@export var SLOW_MOTION_WEAR_OFF = 0.8
@export var SLOW_LENGTH = 0.05

var doubleJump = true
var arrowStartPos : Vector2
var trailTexture
var engineSpeed = 1
var slowedTime = false
var timeSinceSlow = 0

func _ready():
	trailTexture = load("res://white.png")

func _process(delta):
	print(delta)
	var xDirection = Input.get_axis("left", "right")

	velocity.x = move_toward(velocity.x, 0, DECELERATION*delta)
	if(abs(velocity.x) < MAX_SPEED):
		if(velocity.x < 0):
			velocity.x = move_toward(velocity.x, -MAX_SPEED, -xDirection*ACCELERATION*delta)
		else:
			velocity.x = move_toward(velocity.x, MAX_SPEED, xDirection*ACCELERATION*delta)

	if(Input.is_action_just_pressed("click")):
		arrowStartPos = get_global_mouse_position()
	
	if(Input.is_action_pressed("click") and doubleJump and !is_on_floor() and !slowedTime):
		slowedTime = true
		engineSpeed = 0.1
		timeSinceSlow = 0

	if(Input.is_action_just_released("click") and doubleJump and !is_on_floor()):
		var cursorPos = get_global_mouse_position()
		var direction = arrowStartPos.direction_to(cursorPos)
		velocity = -direction*JUMP_STRENGTH
		doubleJump = false
		makeTrail(direction, position)
	
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = -JUMP_STRENGTH

	if(is_on_floor() and !doubleJump):
		doubleJump = true
		
	if(Input.is_action_pressed("click") and !is_on_floor() and doubleJump):
		if(timeSinceSlow < SLOW_LENGTH):
			timeSinceSlow += delta
		else:
			engineSpeed += SLOW_MOTION_WEAR_OFF*delta
			if(engineSpeed >= 1):
				engineSpeed = 1
		$Line2D.global_position = Vector2.ZERO
		var cursorPos = get_global_mouse_position()
		$Line2D.points = [arrowStartPos, cursorPos]
		$Line2D.visible = true
	else:
		engineSpeed = 1
		slowedTime = false
		$Line2D.visible = false
	
	velocity.y += GRAVITY*delta
	Engine.time_scale = engineSpeed

func makeTrail(direction, launchPosition):
	for i in range(4):
		var sprite = Sprite2D.new()
		sprite.texture = trailTexture
		sprite.scale = Vector2(0.5/(i/1.4+1), 0.5/(i/1.4+1))
		sprite.position = launchPosition+direction*(i*20)
		get_tree().root.add_child(sprite)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(sprite.queue_free)
		await get_tree().create_timer(0.03).timeout

	
func _physics_process(_delta):
	move_and_slide()
