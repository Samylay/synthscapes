# Base class for interactable props and NPCs.
# Attach to a Node2D that has a child Area2D named "InteractionZone".
# Subclasses override interact() to define what happens on E press.
extends Node2D

@export var interaction_label: String = "Press E"

@onready var zone: Area2D = $InteractionZone

func _ready() -> void:
	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)
	# Connect to EventBus so interact() is called when player presses E
	EventBus.interaction_triggered.connect(_on_interaction_triggered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_interactable"):
		body.set_interactable(self)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("clear_interactable"):
		body.clear_interactable()


func _on_interaction_triggered(interactable: Node) -> void:
	if interactable == self:
		interact()


func interact() -> void:
	pass  # Override in subclasses
