# Scene 1 — Kaï's apartment. Cutscene → player choice → gameplay in same map.
@tool
extends Node2D

@onready var _dialogue_manager: Node = $DialogueManagerNode
@onready var _npc: Node = $CutsceneNPC
@onready var _hud: Node = $HUD
@onready var _feedback_label: Label = $FeedbackCanvas/FeedbackPanel/FeedbackLabel
@onready var _feedback_panel: PanelContainer = $FeedbackCanvas/FeedbackPanel

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
			_enter_play_mode_force
		),
		DialogueModels.DialogueNode.new(
			"escape_ruse", "Kaï",
			"[Kaï surcharge le fauteuil d'immersion. L'IEM aveugle les drones. Fuite furtive par les conduits d'aération.]",
			DialogueModels.PortraitSide.LEFT, "",
			_enter_play_mode_ruse
		),
	])
	await get_tree().process_frame
	_dialogue_manager.start_conversation(_npc, _hud)


func _enter_play_mode_force() -> void:
	GameState.set_flag("escape_method", "force")
	_enter_play_mode()


func _enter_play_mode_ruse() -> void:
	GameState.set_flag("escape_method", "ruse")
	_enter_play_mode()


func _enter_play_mode() -> void:
	var player: Node2D = $Player
	player.global_position = $SpawnPoint.global_position
	player.visible = true
	player.process_mode = Node.PROCESS_MODE_INHERIT
	_setup_camera_limits()
	$ResolutionZone.body_entered.connect(_on_resolution_zone_entered)
	EventBus.prop_interaction_completed.connect(_on_prop_interaction)


func _setup_camera_limits() -> void:
	var ground: TileMapLayer = $Ground
	var rect: Rect2i = ground.get_used_rect()
	if rect.size == Vector2i.ZERO:
		return
	var ts: Vector2i = ground.tile_set.tile_size
	var cam: Camera2D = $Player/Camera2D
	cam.limit_left   = rect.position.x * ts.x
	cam.limit_top    = rect.position.y * ts.y
	cam.limit_right  = rect.end.x * ts.x
	cam.limit_bottom = rect.end.y * ts.y


func _on_resolution_zone_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		EventBus.resolution_zone_entered.emit()


func _on_prop_interaction(_prop_name: String, prop_data: Dictionary) -> void:
	if "message" in prop_data:
		_feedback_label.text = prop_data["message"]
		_feedback_panel.visible = true
		var tween := create_tween()
		tween.tween_interval(3.0)
		tween.tween_callback(_feedback_panel.set.bind("visible", false))
