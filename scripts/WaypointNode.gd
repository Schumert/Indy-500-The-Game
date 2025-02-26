extends Node2D
class_name WaypointNode


@export var min_distance_to_reach_waypoint = 100
@export var next_waypoint_node : Array[NodePath]
@export var is_crash : bool
@export var is_random_min_distance_allowed: bool
@export var random_max_limit_min_distace_to_reach_waypoint : int = 0


func _ready():
    pass




func _process(delta):
    pass