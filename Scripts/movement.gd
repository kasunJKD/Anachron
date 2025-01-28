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
@export var vfx_footsteps: AudioStream
@onready var sfx_player: AudioStreamPlayer2D = $sfx_player
@onready var push_sfx: AudioStreamPlayer2D = $push_sfx
# Cooldown to prevent overlapping sounds
var footstep_cooldown = 0.0
const COOLDOWN_TIME = 0.2  # Seconds between footsteps

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
	# 1) Determine the tile we want to move onto
	var new_target = target_position
	var dir_vec = Vector2()
	match direction:
		Direction.UP:
			new_target.y -= TILE_SIZE
			dir_vec = Vector2(0, -TILE_SIZE)
		Direction.DOWN:
			new_target.y += TILE_SIZE
			dir_vec = Vector2(0, TILE_SIZE)
		Direction.LEFT:
			new_target.x -= TILE_SIZE
			dir_vec = Vector2(-TILE_SIZE, 0)
		Direction.RIGHT:
			new_target.x += TILE_SIZE
			dir_vec = Vector2(TILE_SIZE, 0)

	# 2) Check for wall collision (layer 1)
	if is_tile_blocked_by_wall(new_target):
		is_moving = false
		return

	# 3) Check if there's a box at new_target
	var first_box = get_box_at_position(new_target)
	if first_box:
		# There's at least one box, so let's try pushing the chain
		var success = push_box_chain(new_target, dir_vec)
		if success:
			# The boxes were pushed, so the player can move in
			target_position = new_target
			is_moving = true
			push_sfx.play()
		else:
			# Chain push failed, do nothing
			is_moving = false
	else:
		# No box => move freely
		target_position = new_target
		is_moving = true

		
#
# CHAIN PUSH LOGIC
#
func push_box_chain(start_pos: Vector2, dir_vec: Vector2) -> bool:
	# 1) Gather all boxes in a line from 'start_pos' outward in 'dir_vec'
	var box_positions = []
	var box_nodes = []

	var current_pos = start_pos
	while true:
		var box_node = get_box_at_position(current_pos)
		if box_node == null:
			# No more boxes in this line
			break
		# We found a box
		box_positions.append(current_pos)
		box_nodes.append(box_node)
		# Move on to the next tile
		current_pos += dir_vec

	# If we found none, that means there's no box chain to push, so no push needed
	if box_nodes.size() == 0:
		return true  # trivial success (the player can move freely)

	# 2) 'current_pos' is now the tile AFTER the last box in the chain
	# Check if that tile is free for the last box to move into
	if is_tile_blocked_by_wall(current_pos):
		return false  # blocked by a wall or something on layer 1
	
	# If there's another box outside our chain here, also blocked
	# (We only handle 1 chain in a line. If there's a second chain behind that, also blocked.)
	var next_box = get_box_at_position(current_pos)
	if next_box != null:
		# Another box that wasn't part of our chain => can't push
		return false

	# 3) We can push! So push from LAST to FIRST
	# For i in range(..., step -1):
	for i in range(box_nodes.size() - 1, -1, -1):
		var box_node = box_nodes[i]
		var old_pos = box_positions[i]
		var new_pos = old_pos + dir_vec
		# Move the box
		# If your Box also uses tile-based movement, set box_node.target_position etc.
		# Otherwise, just set global_position directly:
		box_node.target_position = new_pos
		box_node.is_moving = true
	push_sfx.play()
	return true

#
# WALL / BOX DETECTION
#
func is_tile_blocked_by_wall(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = 1  # layer 1 for walls
	return space_state.intersect_point(query).size() > 0

func get_box_at_position(pos: Vector2) -> Node:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = 2  # layer 2 for boxes

	var collisions = space_state.intersect_point(query)
	if collisions.size() == 0:
		return null

	# Return the first box found. (If multiple boxes overlap exactly, pick any.)
	return collisions[0].collider

#
# SOUND EFFECTS FOR FOOTSTEPS
#
#func load_sfx(sfx_to_load):
	#if sfx_player.stream != sfx_to_load:
		#sfx_player.stop()
		#sfx_player.stream = sfx_to_load
#
#func _play_footstep() -> void:
	#if footstep_cooldown <= 0:
		#if anim_tree.get("parameters/conditions/right"):
			#sfx_player.stream = vfx_footsteps
		#elif anim_tree.get("parameters/conditions/left"):
			#sfx_player.stream = vfx_footsteps
		#sfx_player.play()
		#footstep_cooldown = COOLDOWN_TIME
