extends "res://neft_godot/src/matrix2.gd"

func _init(in_size:int, out_size:int).(in_size, out_size):
	pass

func get_weights() -> Array:
	return to_array()

func set_weights(weights:Array) -> void:
	for i in range(size()):
		_array[i] = weights[i]
		
func get_input_size() -> int:
	return _rows

func get_output_size() -> int:
	return _cols
