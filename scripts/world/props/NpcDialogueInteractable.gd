extends "res://scripts/world/Interactable.gd"

var _nodes: Dictionary = {}
var _start_node_id: String = ""
var _dialogue_manager: Node = null


func configure(display_name: String, start_node_id: String, nodes: Array) -> void:
	interaction_label = "Press E to talk to %s" % display_name
	_start_node_id = start_node_id
	_nodes.clear()
	for node in nodes:
		_nodes[node.id] = node


func _ready() -> void:
	super._ready()
	_dialogue_manager = get_node_or_null("/root/DialogueManagerNode")


func interact() -> void:
	var dm := get_tree().get_first_node_in_group("dialogue_manager")
	if dm == null:
		return
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null:
		return
	dm.start_conversation(self, hud)


func get_start_node() -> DialogueModels.DialogueNode:
	return get_node_by_id(_start_node_id)


func get_node_by_id(node_id: String) -> DialogueModels.DialogueNode:
	if node_id.is_empty():
		return null
	return _nodes.get(node_id, null)
