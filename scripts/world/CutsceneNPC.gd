# Reusable node for cutscene-style dialogue (no player interaction needed).
# Call configure() in the parent scene's _ready(), then pass this node to
# DialogueManager.start_conversation().
extends Node

var _nodes: Dictionary = {}
var _start_id: String = ""


func configure(start_id: String, nodes: Array) -> void:
	_start_id = start_id
	for n in nodes:
		_nodes[n.id] = n


func get_start_node() -> DialogueModels.DialogueNode:
	return _nodes.get(_start_id)


func get_node_by_id(id: String) -> DialogueModels.DialogueNode:
	return _nodes.get(id)
