extends Node

var _rows:int
var _cols:int
var _array:Array

func _init(rows:int, cols:int):
	_rows = rows
	_cols = cols
	_array = []
	var size = _rows * _cols
	for _i in range(size):
		_array.append(0.0)

func make_random(minimum:float, maximum:float) -> void:
	for i in range(size()):
		_array[i] = rand_range(minimum, maximum)

func index(i:int, j:int) -> int:
	return i * _cols + j

func size() -> int:
	return _array.size()

func to_array() -> Array:
	return _array

func set_value(i:int, j:int, value:float) -> void:
	_array[index(i, j)] = value

func get_value(i:int, j:int) -> float:
	return _array[index(i, j)]

static func mult(A:Array, B) -> Array:
	# see https://en.wikipedia.org/wiki/Matrix_multiplication_algorithm
	# for details
	
	if A.size() != B._rows:
		print("Matrix2::>Warning: Incompatible multiplication ")
		print(str(A.size()) + "x" + str(B.size()))
		return []

	var C:Array = []
	for _i in range(B._cols):
		C.append(0.0)
		
	for j in range(B._cols):
		var sum:float = 0
		for k in range(B._rows):
			sum += A[k] * B.get_value(k, j)
			C[j] = sum;
	
	return C

func _to_string() -> String:
	var out:String = ""
	out += "[" + str(_rows) + "x" + str(_cols) + "]"
	for i in range(_rows):
		out += "\n" + "|"
		for j in range(_cols):
			var str_value = "%+5.2f" % get_value(i, j) # format output
			out += str_value + " "
		out += "|"
	
	return out
