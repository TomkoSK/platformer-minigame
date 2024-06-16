extends Node2D


@export var player : Node2D

func _on_area_2d_body_entered(body):
	if(body == player):
		player.doubleJump = true
		queue_free()