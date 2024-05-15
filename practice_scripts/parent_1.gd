class_name parent_1
extends Node

signal signal_name

func _ready():
	signal_name.connect(method_on_the_object)

var method_name = "do"

func method_on_the_object():
	print("signal emitted")

