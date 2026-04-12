# Base class for interactable props and NPCs.
# Attach to a Node2D that has a child Area2D named "InteractionZone".
# Subclasses override interact() to define what happens on E press.
extends Node2D

@export var interaction_label: String = "Press E"

@onready var zone: Area2D = $InteractionZone

func _ready() -> void:
	# Player's InteractionArea is on collision_layer=2; zone mask=2 detects it via area_entered.
	zone.area_entered.connect(_on_area_entered)
	zone.area_exited.connect(_on_area_exited)
	# Connect to EventBus so interact() is called when player presses E
	EventBus.interaction_triggered.connect(_on_interaction_triggered)


func _on_area_entered(area: Area2D) -> void:
	var body := area.get_parent()
	if body.has_method("set_interactable"):
		body.set_interactable(self)


func _on_area_exited(area: Area2D) -> void:
	var body := area.get_parent()
	if body.has_method("clear_interactable"):
		body.clear_interactable()


func _on_interaction_triggered(interactable: Node) -> void:
	if interactable == self:
		interact()


func interact() -> void:
	pass  # Override in subclasses
