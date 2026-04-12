extends Node2D

@onready var _feedback_label: Label = $FeedbackCanvas/FeedbackPanel/FeedbackLabel
@onready var _feedback_panel: PanelContainer = $FeedbackCanvas/FeedbackPanel


func _ready() -> void:
	GameState.reset_dialogue_challenge()
	_setup_camera_limits()
	_place_player_at_spawn()
	EventBus.prop_interaction_completed.connect(_on_prop_interaction)
	_setup_archivist()
	_start_audio()


func _setup_camera_limits() -> void:
	var ground: TileMapLayer = $Ground
	var rect: Rect2i = ground.get_used_rect()
	if rect.size == Vector2i.ZERO:
		return
	var ts: Vector2i = ground.tile_set.tile_size
	var cam: Camera2D = $YSortables/Player/Camera2D
	cam.limit_left   = rect.position.x * ts.x
	cam.limit_top    = rect.position.y * ts.y
	cam.limit_right  = rect.end.x * ts.x
	cam.limit_bottom = rect.end.y * ts.y


func _place_player_at_spawn() -> void:
	$YSortables/Player.global_position = $SpawnPoint.global_position


func _setup_archivist() -> void:
	var npc: Node = $YSortables/Archivist
	if npc == null:
		return
	npc.configure(
		"Archivist",
		"intro",
		[
			DialogueModels.DialogueNode.new(
				"intro",
				"Archivist",
				"Before I open the archive, answer this. Which system woke the eastern gate in the previous chamber?",
				DialogueModels.PortraitSide.LEFT,
				"",
				Callable(),
				[
					DialogueModels.DialogueChoice.new("The relay terminal.", "correct"),
					DialogueModels.DialogueChoice.new("The rooftop beacon.", "wrong"),
				]
			),
			DialogueModels.DialogueNode.new(
				"correct",
				"Archivist",
				"Correct. You were paying attention. I'll open the gate.",
				DialogueModels.PortraitSide.LEFT,
				"",
				GameState.resolve_dialogue
			),
			DialogueModels.DialogueNode.new(
				"wrong",
				"Archivist",
				"Wrong. The beacon only broadcasts. Think it through and ask again.",
				DialogueModels.PortraitSide.LEFT
			),
		]
	)


func _on_prop_interaction(_prop_name: String, prop_data: Dictionary) -> void:
	if "message" in prop_data:
		_feedback_label.text = prop_data["message"]
		_feedback_panel.visible = true
		var tween := create_tween()
		tween.tween_interval(3.0)
		tween.tween_callback(_feedback_panel.set.bind("visible", false))


func _start_audio() -> void:
	var music := load("res://assets/audio/music/ambient_placeholder.ogg")
	if music:
		AudioManager.play_music(music)
	var ambience := load("res://assets/audio/sfx/ambience_placeholder.ogg")
	if ambience:
		AudioManager.play_ambience(ambience)
