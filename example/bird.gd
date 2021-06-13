extends RigidBody2D

var _is_dead:bool = false
var _respawn:bool = false # variable for _integrate_forces() interactions
export(int) var jump_force:int = 800

func _ready():
	# 3 inputs, 2 hidden layers, 1 output:
	#$Organism.init_nn(3, [7, 4], 1)
	
	# random color
	modulate.r = rand_range(0.5, 1)
	modulate.g = rand_range(0.5, 1)
	modulate.b = rand_range(0.5, 1)
	
	# initial position
	position = Vector2(
			0.2 * get_viewport_rect().size.x,
			0.5 * get_viewport_rect().size.y)

func _integrate_forces(state):
	# use integrate forces because we need to teleport the rigidbody
	# when respawning the birds
	# Teleporting the RigidBody makes a lot of glitches
	
	if !is_dead() && !_respawn:
		$Organism.add_fitness(0.1) # Increase the fitness each frame if alive
								   # The step is 0.1 to avoid dealing 
								   # with huge numbers
		
		# check collisions with screen borders
		var collide_with_screen_top = position.y < 0
		var collide_with_screen_bot = position.y > get_viewport_rect().size.y
		if collide_with_screen_top || collide_with_screen_bot:
			kill()
	
	
	if _respawn:
		# teleport to initial position and reset physics
		state.transform.origin = Vector2(
			0.2 * get_viewport_rect().size.x,
			0.5 * get_viewport_rect().size.y)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		state.set_angular_velocity(0.0)
		applied_force = Vector2.ZERO
		applied_torque = 0.0
		
		_respawn = false

func _apply_neural_net_decision() -> void:
	# get closest wall target
	var closest_wall = Global.wall_manager.get_closest(position)
	$RayCast2D.cast_to = closest_wall.position - position
	var target:Vector2 = closest_wall.position - position
	
	# add neural net inputs
	var inputs:Array = []
	# normalize inputs as much as possible
	# our Organism is set with 3 inputs so we give it 3 inputs
	inputs.push_back(target.x / get_viewport_rect().size.x)
	inputs.push_back(target.y / get_viewport_rect().size.y)
	inputs.push_back(0.01 * linear_velocity.y)
	
	# calculate neural net outputs
	var output:Array = $Organism.think(inputs)
	var should_jump:bool = true if output[0] > 0 else false
	
	# take decision from the output
	if should_jump:
		apply_central_impulse(Vector2(0, -jump_force))

func _physics_process(_delta):
	if !_is_dead:
		_apply_neural_net_decision()

func kill() -> void:
	_is_dead = true
	hide()

func respawn() -> void:
	_respawn = true # send information for _integrate_forces()
	_is_dead = false
	show()

func is_dead() -> bool:
	return _is_dead
