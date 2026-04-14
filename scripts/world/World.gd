@tool
extends Node2D

@onready var _feedback_label: Label = $FeedbackCanvas/FeedbackPanel/FeedbackLabel
@onready var _feedback_panel: PanelContainer = $FeedbackCanvas/FeedbackPanel

@export var ambient_music: AudioStream
@export var ambient_loop: AudioStream

@warning_ignore("unused_private_class_variable")
@export_tool_button("Build Map in Editor") var _build_map_button := _editor_build_map

func _editor_build_map() -> void:
	if not Engine.is_editor_hint():
		return
	Level1Builder.build($Ground, $YSortables/Walls)
	print("Level 1 map built — save the scene to persist.")


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	GameState.reset()
	Level1Builder.build($Ground, $YSortables/Walls)
	_setup_camera_limits()
	_place_player_at_spawn()
	_connect_resolution_zone()
	EventBus.prop_interaction_completed.connect(_on_prop_interaction)
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


func _connect_resolution_zone() -> void:
	$ResolutionZone.body_entered.connect(_on_resolution_zone_entered)


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


func _start_audio() -> void:
	if ambient_music:
		AudioManager.play_music(ambient_music)
	elif FileAccess.file_exists("res://assets/audio/music/ambient_placeholder.ogg"):
		var music := load("res://assets/audio/music/ambient_placeholder.ogg")
		if music:
			AudioManager.play_music(music)
	if ambient_loop:
		AudioManager.play_ambience(ambient_loop)
	elif FileAccess.file_exists("res://assets/audio/sfx/ambience_placeholder.ogg"):
		var ambience := load("res://assets/audio/sfx/ambience_placeholder.ogg")
		if ambience:
			AudioManager.play_ambience(ambience)
