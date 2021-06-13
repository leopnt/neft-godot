tool
extends Node2D

const WallScene = preload("res://example/Wall.tscn")
const Wall = preload("res://example/wall.gd")

export(int) var size:int = 3 setget set_size
# number of visible walls

var _separation:int

export(int) var wall_speed:int = 200

func set_size(new_size:int) -> void:
	# manage walls in editor
	
	if Engine.editor_hint:
		size = new_size
		if size < 2:
			size = 2
		
		# delete every walls
		for child in get_children():
			child.free()
		
		var screen_size:Vector2 = get_viewport_rect().size
		
		_separation = int(screen_size.x / float(size))
		
		# add new walls
		for _i in range(size):
			var new_wall = WallScene.instance()
			add_child(new_wall, true)
			new_wall.set_owner(get_tree().get_edited_scene_root())
		
		reset()

func _ready():
	if !Engine.editor_hint:
		Global.wall_manager = self
		_separation = int(get_viewport_rect().size.x / float(size))

func _physics_process(delta):
	if !Engine.editor_hint:
		for child in get_children():
			child.position += Vector2(-wall_speed * delta, 0) # move wall
			if child.position.x < 0: # respawn on the right if out of screen
				child.position.x = get_viewport_rect().size.x
				child.position.y = rand_range(
					0.4 * get_viewport_rect().size.y,
					0.6 * get_viewport_rect().size.y)


func get_closest(from:Vector2) -> Wall:
	var closest_pos:float = get_viewport_rect().size.x
	var closest_wall:Wall = get_children()[0]
	for wall in get_children():
		if wall.position.x < closest_pos && wall.position.x > from.x:
			closest_wall = wall
			closest_pos = wall.position.x
	
	return closest_wall

func reset() -> void:
	for i in range(get_child_count()):
		get_children()[i].position.x = i * _separation # wall repartition
		
		# add initial offset
		get_children()[i].position.x += get_viewport_rect().size.x
		
		# random height
		get_children()[i].position.y = rand_range(
			0.4 * get_viewport_rect().size.x,
			0.6 * get_viewport_rect().size.y) 
