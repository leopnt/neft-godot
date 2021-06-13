extends Node

const Matrix2 = preload("res://neft_godot/src/matrix2.gd")
const Layer = preload("res://neft_godot/src/layer.gd")

var _input_size
var _output_size
var _layers:Array

func _init(input_size:int, output_size:int):
	_input_size = input_size
	_output_size = output_size
	_layers = []
	_layers.append(Layer.new(_input_size +1, _output_size)) # +1 for the bias

	make_random(-1, 1)

func add_layer(input_size:int) -> void:
	# modify last layer to match with the next new layer
	var last_layer_index:int = _layers.size() -1
	var last_input_size:int = _layers[last_layer_index].get_input_size()
	_layers[last_layer_index] = Layer.new(last_input_size, input_size)
	
	# add last layer
	var newLayer:Layer = Layer.new(input_size +1, _output_size) # +1 for bias
	_layers.append(newLayer)
	
	make_random(-1, 1)

func make_random(minimum:int, maximum:int) -> void:
	for i in range(_layers.size()):
		_layers[i].make_random(minimum, maximum)

func output(inputs:Array) -> Array:
	# calculate output from input
	
	if inputs.size() != _input_size:
		push_error(
			"NN::>Error: inputs size doesn't match neural net input size")
		return []
	
	# what will go through the NN
	var impulse:Array = inputs.duplicate(true)
	
	for layer in _layers:
		# prepare next input with bias
		var biased_impulse:Array = impulse.duplicate(true)
		biased_impulse.append(1.0)
		
		# feed forward with the current layer
		impulse = Matrix2.mult(biased_impulse, layer)
		
		# pass the output through the activation function
		activate(impulse)
	
	return impulse

func get_input_size() -> int:
	return _input_size

func get_output_size() -> int:
	return _output_size

func get_layers() -> Array:
	return _layers

func get_weights() -> Array:
	var weights = []
	for layer in _layers:
		for weight in layer.get_weights():
			weights.push_back(weight)
	
	return weights;

func set_weights(weights:Array) -> void:
	var block_index:int = 0
	for i in range(_layers.size()):
		# extract layer weights from full NN weights
		# (do a deep copy of the block)
		var layer_block:Array = weights.slice(
			block_index, block_index + _layers[i].size(), 1, true)
		
		# then set the layer with the extracted sub array corresponding
		# to this layer
		_layers[i].set_weights(layer_block)
		block_index += _layers[i].size()

static func activate(arr:Array) -> void:
	for i in range(arr.size()):
		arr[i] = tanh(arr[i])

func _to_string() -> String:
	var out:String = ""
	out += "NN[in: " + str(_input_size) + " +1 "
	out += "==> out: " + str(_output_size)
	out += "]\n"
	out += "|< in" + "\n" + "v" + "\n";
	for layer in _layers:
		out += layer.to_string() + "\n";
		out += "v" + "\n"
	
	out += "|> out"
	
	return out
