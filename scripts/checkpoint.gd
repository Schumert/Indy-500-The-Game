extends Area2D

@export var checkpoint_id:int
var player

func _on_body_entered(body):
	if body.collision_layer & (1 << 1) != 0:
		player = "car1"
	
	if body.collision_layer & (1 << 4) != 0 or body.collision_layer & (1<<7) != 0:
		player = "car2"
	
	if Global.is_checkpoint_in_order(player, checkpoint_id):
		Global.add_checkpoint(player, checkpoint_id)
	
		
