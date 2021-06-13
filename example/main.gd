extends Node2D

var perf_data:Array = []

func _ready():
	randomize()

func _process(_delta):
	check_and_apply_next_generation()
	
func check_and_apply_next_generation() -> void:
	var best_score = $Population.get_best().get_node("Organism").get_fitness()
	$CanvasLayer/Display.text =  "Score: " + str(int(best_score)) + "\n"
	
	var ready_for_next_generation:bool = false
	var death_counter:int = 0
	for bird in $Population.get_children():
		if bird.is_dead():
			death_counter += 1
	
	$CanvasLayer/Display.text += "Remaining: " + str(
		$Population.get_child_count() - death_counter) + "\n"
	
	$CanvasLayer/Display.text += "Generation: " + str(
		$Population.get_generation())
	
	if death_counter == $Population.get_child_count():
		ready_for_next_generation = true
	
	if ready_for_next_generation:
		# keep data to be saved later
		var row:Array = [OS.get_ticks_msec() * 0.001, best_score]
		perf_data.push_back(row)
		
		$Population.next_generation()
		for bird in $Population.get_children():
			bird.respawn()
		
		$WallManager.reset()

func _input(event) -> void:
	if event.is_action_pressed("ui_up"):
		Engine.time_scale += 1
	if event.is_action_pressed("ui_down"):
		Engine.time_scale = 1
	
	if event.is_action_pressed("ui_right"):
		write_csv("perf_data.csv", perf_data)
	
	if event.is_action_pressed("ui_left"):
		var best_score = $Population.get_best().get_node(
			"Organism").get_fitness()
		var row:Array = [OS.get_ticks_msec() * 0.001, best_score]
		perf_data.push_back(row)
		print("saved entry")

func write_csv(file_name, data:Array) -> void:
	# save data for learning performance analysis
	
	var file = File.new()
	file.open(file_name, File.WRITE)
	for row in data:
		file.store_csv_line(row)
	
	file.close()
	print("Data saved as .csv")
