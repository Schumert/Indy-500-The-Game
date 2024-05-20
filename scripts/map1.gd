extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.start_pos = $StartPos.global_position
	Global.start_pos2 = $StartPos2.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
