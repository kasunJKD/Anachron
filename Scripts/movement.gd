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

func _ready():
	# Initialize target position to the player's starting position
	# Register this player in the Globals script so it knows about us
	StateMech.register_player(self)
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
		

#func attempt_move(direction: int):
	## Calculate the target position based on direction
	#var new_target = target_position
	#match direction:
		#Direction.UP:
			#new_target.y -= TILE_SIZE
		#Direction.DOWN:
			#new_target.y += TILE_SIZE
		#Direction.LEFT:
			#new_target.x -= TILE_SIZE
		#Direction.RIGHT:
			#new_target.x += TILE_SIZE
#
	## Check collisions before moving
	#if !is_tile_blocked(new_target):
		#target_position = new_target
		#is_moving = true

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

#func is_tile_blocked(target: Vector2) -> bool:
	## Check for collisions using PhysicsShapeQueryParameters2D with collision mask 1
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsShapeQueryParameters2D.new()
	#for child in get_children():
		#if child is CollisionShape2D:
			#query.shape = child.shape
			#query.transform = Transform2D().translated(target - position)
			#query.collide_with_bodies = false
			#query.collide_with_areas = false
			#query.collision_mask = 1  # Set the collision mask to 1
			#var collisions = space_state.intersect_shape(query)
			#if collisions.size() > 0:
				#return true
	#return false
