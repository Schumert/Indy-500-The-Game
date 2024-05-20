extends Node

var current_checkpoint_index = 0
var checkpoints = []
var finish_line
var is_checkpoints_finished:= false

# Called when the node enters the scene tree for the first time.
func _ready():
	checkpoints = [
		$Checkpoint1,
		$Checkpoint2,
		$Checkpoint3,
	]
	finish_line = $FinishLine

	for checkpoint in checkpoints:
		checkpoint.connect("player_entered", _on_checkpoint_entered.bind(checkpoint))
	
	finish_line.connect("player_entered", _on_finish_line_entered )

func _on_checkpoint_entered(checkpoint):
	if checkpoints[current_checkpoint_index] == checkpoint:
		current_checkpoint_index += 1

		if current_checkpoint_index >= checkpoints.size():
			is_checkpoints_finished = true
			current_checkpoint_index = 0

func _on_finish_line_entered():
	if is_checkpoints_finished:
		Global.player_cross_checkpoint.finish_lap()
		is_checkpoints_finished = false
