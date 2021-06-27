extends Node

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().paused = !get_tree().paused
