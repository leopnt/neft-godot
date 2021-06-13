extends Node

var _genes:Array = []

func mutate(mutation_rate:float, minimum:float, maximum:float) -> void:
	# pick a gene and randomize it with a probability of mutationRate
	for i in range(_genes.size()):
		var r:float = rand_range(0.0, 1.0)
		if r < mutation_rate:
			 _genes[i] = rand_range(minimum, maximum)

func get_genes() -> Array:
	return _genes
	
func set_genes(genes:Array) -> void:
	_genes = genes

static func crossgenes(A:Array, B:Array) -> Array:
	var dna_size:int = A.size()
	var separator:int = int(rand_range(0, dna_size))
	
	var crossed_genes:Array = []
	for i in range(separator):
		# add parentA genes
		crossed_genes.push_back(A[i])
	
	for i in range(separator, dna_size):
		# add parentB genes
		crossed_genes.push_back(B[i])
	
	return crossed_genes

func _to_string():
	return str(_genes)
