extends Node

const NN = preload("res://neft_godot/src/nn.gd")
const DNA = preload("res://neft_godot/src/dna.gd")

export(int) var input_size:int = 2
export(Array, int, 1, 100) var hidden_layers_sizes:Array = [2, 2]
# layers must be of sizes above 1
export(int) var output_size:int = 1

var _fitness:float = 0.0
var _brain:NN
var _dna:DNA

func _ready() -> void:
	# init the neural network with base input output
	_brain = NN.new(input_size, output_size)
	
	# then add hidden layers
	for layer_size in hidden_layers_sizes:
		_brain.add_layer(layer_size)
	
	_dna = DNA.new()
	_dna.set_genes(_brain.get_weights())
	# It is very important to update DNA each time there is a modification
	# on the neural net and vice-versa.
	# It is on the responsability of this class to give approriate set/get
	# and handle it correctly

func get_brain() -> NN:
	return _brain

func think(inputs:Array) -> Array:
	return _brain.output(inputs)

func get_dna() -> DNA:
	return _dna

func set_dna(dna:DNA) -> void:
	_dna.set_genes(dna.get_genes())
	_brain.set_weights(_dna.get_genes())

func get_fitness() -> float:
	return _fitness

func set_fitness(fitness:float) -> void:
	_fitness = fitness

func add_fitness(amount:float) -> void:
	_fitness += amount

func mutate(mut_rate:float) -> void:
	_dna.mutate(mut_rate, -1.0, 1.0) # fixed because nn takes values -1 to 1
	_brain.set_weights(_dna.get_genes())

static func crossover(parentA, parentB):
	# use parentA as an exemple for the child
	var dna_size:int = parentA.get_dna().get_genes().size()
	var separator:int = randi() % dna_size
	
	var crossed_genes:Array = []
	for i in range(separator):
		# add parentA genes
		crossed_genes.push_back(parentA.get_dna().get_genes()[i])
	
	for i in range(separator, dna_size):
		# add parentB genes
		crossed_genes.push_back(parentB.get_dna().get_genes()[i])
	
	var child = parentA
	child.get_dna().set_genes(crossed_genes)
	# Set the new crossover genes: the only thing that changes between children
	# and parents.
	# We keep the topology but the neural net weights are updated in set_dna()
	
	return child
