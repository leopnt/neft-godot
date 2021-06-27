extends Area2D

const Bird = preload("res://example/flappy_bird/src/bird.gd")


func _on_Wall_body_entered(body):
	if body is Bird:
		body.kill()
