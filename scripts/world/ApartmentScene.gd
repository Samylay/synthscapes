# Scene 1 — Kaï's apartment. Level 1: "Le contrat".
# Auto-launched cutscene → player choice → transition to World.
@tool
extends Node2D

@onready var _dialogue_manager: Node = $DialogueManagerNode
@onready var _npc: Node = $CutsceneNPC
@onready var _hud: Node = $HUD

@warning_ignore("unused_private_class_variable")
@export_tool_button("Build Apartment Map in Editor") var _build_btn := _editor_build_map

func _editor_build_map() -> void:
	if not Engine.is_editor_hint():
		return
	ApartmentBuilder.build($Ground, $Walls)
	print("Apartment map built — save the scene to persist.")


func _ready() -> void:
	ApartmentBuilder.build($Ground, $Walls)
	if Engine.is_editor_hint():
		return
	_npc.configure("jax_wake", [
		DialogueModels.DialogueNode.new(
			"jax_wake", "Jax",
			"Debout, Kaï. Un contrat urgent vient de tomber. Tu as soixante-douze heures avant la dissolution.",
			DialogueModels.PortraitSide.RIGHT, "kai_refuse"
		),
		DialogueModels.DialogueNode.new(
			"kai_refuse", "Kaï",
			"Je ne travaille pas de nuit, Jax. Trouve un autre Passeur.",
			DialogueModels.PortraitSide.LEFT, "jax_contract"
		),
		DialogueModels.DialogueNode.new(
			"jax_contract", "Jax",
			"Ce contrat paie le triple. La cliente s'appelle Lina Vorne. Morte ce matin. Branche-toi et récupère ses dernières mémoires.",
			DialogueModels.PortraitSide.RIGHT, "kai_accept"
		),
		DialogueModels.DialogueNode.new(
			"kai_accept", "Kaï",
			"Très bien. J'amorce la séquence d'immersion.",
			DialogueModels.PortraitSide.LEFT, "kai_install"
		),
		DialogueModels.DialogueNode.new(
			"kai_install", "—",
			"[Kaï s'installe dans le fauteuil et branche les électrodes. L'environnement se dissout dans un souvenir lumineux.]",
			DialogueModels.PortraitSide.LEFT, "lina_memory_1"
		),
		DialogueModels.DialogueNode.new(
			"lina_memory_1", "Lina (Souvenir)",
			"Kaï... Tu m'as promis de continuer à vivre. Tu te souviens de notre promesse ?",
			DialogueModels.PortraitSide.RIGHT, "kai_confused"
		),
		DialogueModels.DialogueNode.new(
			"kai_confused", "Kaï",
			"Qui êtes-vous ? Comment connaissez-vous mon nom ?",
			DialogueModels.PortraitSide.LEFT, "lina_memory_2"
		),
		DialogueModels.DialogueNode.new(
			"lina_memory_2", "Lina (Souvenir)",
			"Tu as gardé la fleur. C'est bien... Ne m'oublie pas complètement.",
			DialogueModels.PortraitSide.RIGHT, "memory_break"
		),
		DialogueModels.DialogueNode.new(
			"memory_break", "—",
			"[Le souvenir se brise violemment. Kaï se réveille en sursaut dans son appartement.]",
			DialogueModels.PortraitSide.LEFT, "alarm"
		),
		DialogueModels.DialogueNode.new(
			"alarm", "Système d'alarme",
			"Intrusion détectée. Escouade de Scrubbers en approche.",
			DialogueModels.PortraitSide.RIGHT, "kai_react"
		),
		DialogueModels.DialogueNode.new(
			"kai_react", "Kaï",
			"Des drones tueurs corporatistes ? Pourquoi ils s'intéressent à une simple extraction ? Ils ont défoncé la porte, je dois réagir vite.",
			DialogueModels.PortraitSide.LEFT, "",
			Callable(),
			[
				DialogueModels.DialogueChoice.new(
					"\"Pas le temps de faire dans la dentelle.\" [La force]",
					"escape_force"
				),
				DialogueModels.DialogueChoice.new(
					"\"Ils sont trop nombreux pour une attaque frontale.\" [La ruse]",
					"escape_ruse"
				),
			]
		),
		DialogueModels.DialogueNode.new(
			"escape_force", "Kaï",
			"[Kaï dégaine son arme. Une fuite par la force — brutale et sanglante.]",
			DialogueModels.PortraitSide.LEFT, "",
			_go_to_world_force
		),
		DialogueModels.DialogueNode.new(
			"escape_ruse", "Kaï",
			"[Kaï surcharge le fauteuil d'immersion. L'IEM aveugle les drones. Fuite furtive par les conduits d'aération.]",
			DialogueModels.PortraitSide.LEFT, "",
			_go_to_world_ruse
		),
	])
	await get_tree().process_frame
	_dialogue_manager.start_conversation(_npc, _hud)


func _go_to_world_force() -> void:
	GameState.set_flag("escape_method", "force")
	SceneManager.call_deferred("change_scene", "res://scenes/world/World.tscn")


func _go_to_world_ruse() -> void:
	GameState.set_flag("escape_method", "ruse")
	SceneManager.call_deferred("change_scene", "res://scenes/world/World.tscn")
