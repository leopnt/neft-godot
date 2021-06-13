extends Node

const Organism = preload("res://neft_godot/src/organism.gd")
const DNA = preload("res://neft_godot/src/dna.gd")

var _generation:int
export(float, EXP, 0.01, 1.0, 0.01) var _mutation_rate:float

export(int) var size:int = 100 # the number of individuals in the population
export(PackedScene) var organism_parent_scene
# Scene reference to a scene that contains an Organism as child

func _ready() -> void:
	# add nodes that contain Organism child into the population
	for _i in range(size):
		var new_child:Node = organism_parent_scene.instance()
		add_child(new_child)

func _calc_fitness() -> void:
	# normalize the fitness according to the population
	var fit_sum:float = 0.0
	for i in range(get_child_count()):
		get_child(i).get_node("Organism").set_fitness(
			0.01 * pow(get_child(i).get_node("Organism").get_fitness(), 2))
		# increase the score squared to give more importance to those
		# who are better
		
		fit_sum += get_child(i).get_node("Organism").get_fitness()
	
	for i in range(get_child_count()):
		get_child(i).get_node("Organism").set_fitness(
			get_child(i).get_node("Organism").get_fitness() / (fit_sum + 1))
		# avoid zero-division errors by adding 1

func _get_dna_mating_pool() -> Array:
	# return a mating pool with each parents in proportion to their fitnesses.
	# The mating pool is made of genes array from dna of parents
	# and so does not contains Nodes
	
	var mating_pool:Array = []
	for individual in get_children():
		var indi_percent:int = int(ceil(
			individual.get_node("Organism").get_fitness() * 100.0 + 1.0))
		
		for _i in range(indi_percent):
			mating_pool.push_back(
				individual.get_node("Organism").get_dna().get_genes())
	
	return mating_pool

func _pick_parent(mating_pool:Array):
	var r:int = int(rand_range(0, mating_pool.size()))
	return mating_pool[r]

func add_individual(individual:Node) -> void:
	add_child(individual)

func get_indiviual(i:int) -> Node:
	return get_child(i)

func get_individuals() -> Array:
	return get_children()

func get_mutation_rate() -> float:
	return _mutation_rate

func get_generation() -> int:
	return _generation

func get_best() -> Node:
	# return the best individual
	
	var best_fit:float = get_child(0).get_node("Organism").get_fitness()
	var best_index:int = 0
	for i in range(1, get_child_count()):
		if get_child(i).get_node("Organism").get_fitness() > best_fit:
			best_fit = get_child(i).get_node("Organism").get_fitness()
			best_index = i
	
	return get_child(best_index)

func next_generation() -> void:
	_calc_fitness()
	var mating_pool:Array = _get_dna_mating_pool()

	# begin reproduction
	for i in range(get_child_count()):
		var parentA_dna:Array = _pick_parent(mating_pool)
		var parentB_dna:Array = _pick_parent(mating_pool)
		
		var crossed_genes:Array = DNA.crossgenes(
			parentA_dna, parentB_dna)
		
		var crossed_dna:DNA = DNA.new()
		crossed_dna.set_genes(crossed_genes)
		
		get_child(i).get_node("Organism").set_dna(crossed_dna)
		get_child(i).get_node("Organism").mutate(_mutation_rate)
		get_child(i).get_node("Organism").set_fitness(0)
		# reset fitness so user don't have to
		
	# end of reproduction
	
	_generation += 1
