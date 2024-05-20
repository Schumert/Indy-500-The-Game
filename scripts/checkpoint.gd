extends Node

signal player_entered


func _on_body_entered(body):
	if body.collision_layer & (1 << 1) != 0:
		Global.player_cross_checkpoint = body
		player_entered.emit()
		
