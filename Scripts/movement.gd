extends CharacterBody2D

# Define tile size
const TILE_SIZE = 32

# Movement directions
enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

# Movement speed (determines duration of one tile movement)
var move_speed = 80.0
var target_position : Vector2
var is_moving = false

@onready var anim_tree: AnimationTree = $AnimationTree
#var state_machine

func _ready():

	# Initialize target position to the player's starting position
	# Register this player in the Globals script so it knows about us
	StateMech.register_player(self)
	
	anim_tree.active = true 
	#var state_machine = anim_tree.get("parameters/playback")
	#state_machine.travel("idle")
	
	#target_position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	#position = target_position
	target_position = global_position

func _physics_process(delta):
	if is_moving:
		# Smoothly move towards the target position
		var distance = target_position - global_position
		if distance.length() > 1:
			velocity = (distance.normalized() * move_speed)
			move_and_slide()
		else:
			global_position = target_position
			velocity = Vector2.ZERO
			is_moving = false
			StateMech.store_game_state()
	
	_update_animation_conditions()

func _input(event):
	if event is InputEventKey and event.pressed:
		if not is_moving:
			match event.keycode:
				KEY_UP:
					attempt_move(Direction.UP)
				KEY_DOWN:
					attempt_move(Direction.DOWN)
				KEY_LEFT:
					attempt_move(Direction.LEFT)
				KEY_RIGHT:
					attempt_move(Direction.RIGHT)

#func _update_animation():
	## If basically standing still
	#if velocity.length() < 0.1:
		#state_machine.travel("idle")
		#return
#
	## Movement is non-zero. Check horizontal velocity first:
	#if velocity.x > 0:
		#state_machine.travel("walk_right")
	#elif velocity.x < 0:
		#state_machine.travel("walk_left")
	#else:
		## velocity.x == 0 => up or down => you want WalkRight
		#state_machine.travel("walk_left")
		
func _update_animation_conditions():
	# We'll set exactly one of these to "true" at a time for clarity.
	if velocity.length() < 0.1:
		anim_tree.set("parameters/conditions/idle", true)
		anim_tree.set("parameters/conditions/left", false)
		anim_tree.set("parameters/conditions/right", false)
	else:
		anim_tree.set("parameters/conditions/idle", false)

		# Check direction
		if velocity.x < 0:
			anim_tree.set("parameters/conditions/left", true)
			anim_tree.set("parameters/conditions/right", false)
		elif velocity.x > 0:
			anim_tree.set("parameters/conditions/left", false)
			anim_tree.set("parameters/conditions/right", true)
		else:
			# If strictly vertical movement:
			# Decide if you want to treat up/down as 'right' or 'left'?
			anim_tree.set("parameters/conditions/left", false)
			anim_tree.set("parameters/conditions/right", true)

func is_tile_blocked(target: Vector2) -> bool:
	# Check for collisions using collision layers or areas
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = target
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = 1

	var collision = space_state.intersect_point(query)
	return collision.size() > 0
	
func attempt_move(direction: int):
	# Calculate the target position based on direction
	var new_target = target_position
	match direction:
		Direction.UP:
			new_target.y -= TILE_SIZE
		Direction.DOWN:
			new_target.y += TILE_SIZE
		Direction.LEFT:
			new_target.x -= TILE_SIZE
		Direction.RIGHT:
			new_target.x += TILE_SIZE

	# Snap the new target to the middle of the tile
	#new_target = new_target.snapped(Vector2(TILE_SIZE, TILE_SIZE))

	if !is_tile_blocked(new_target):
		target_position = new_target
		is_moving = true
	else:
		# Ensure movement can continue after collision
		is_moving = false
