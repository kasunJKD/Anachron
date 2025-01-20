extends CharacterBody2D

var target_position: Vector2
var move_speed = 80.0
var is_moving = false

func _ready():
	add_to_group("boxes")
	target_position = global_position

func _physics_process(delta):
	if is_moving:
		var distance = target_position - global_position
		if distance.length() > 1:
			velocity = distance.normalized() * move_speed
			move_and_slide()
		else:
			global_position = target_position
			velocity = Vector2.ZERO
			is_moving = false
