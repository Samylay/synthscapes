# Scene 1 — Kaï's apartment.
# Static background + auto-launched dialogue → transition to World.
extends Node2D

@onready var _dialogue_manager: Node = $DialogueManagerNode
@onready var _npc: Node = $CutsceneNPC
@onready var _hud: Node = $HUD


func _ready() -> void:
	_npc.configure("wake", [
		DialogueModels.DialogueNode.new(
			"wake", "Kaï",
			"Another run in the chair. My head is full of static.",
			DialogueModels.PortraitSide.LEFT, "threat"
		),
		DialogueModels.DialogueNode.new(
			"threat", "Kaï",
			"The network feed just dropped. They traced me.",
			DialogueModels.PortraitSide.LEFT, "breach"
		),
		DialogueModels.DialogueNode.new(
			"breach", "—",
			"[BOOM. The front door explodes inward. Smoke floods the room.]",
			DialogueModels.PortraitSide.LEFT, "move"
		),
		DialogueModels.DialogueNode.new(
			"move", "Kaï",
			"Scrubbers. Move.",
			DialogueModels.PortraitSide.LEFT, "",
			_go_to_world
		),
	])
	await get_tree().process_frame
	_dialogue_manager.start_conversation(_npc, _hud)


func _go_to_world() -> void:
	SceneManager.call_deferred("change_scene", "res://scenes/world/World.tscn")
