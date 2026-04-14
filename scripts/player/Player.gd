extends CharacterBody2D

const SPEED := 80.0
const SPRINT_SPEED := 140.0

var _current_interactable: Node = null
var _input_locked: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var prompt_label: Label = $PromptCanvas/PromptLabel

@export var footstep_sounds: AudioStreamRandomizer

var _footstep_timer: Timer
var _footstep_player: AudioStreamPlayer2D


func _ready() -> void:
	_footstep_timer = Timer.new()
	_footstep_timer.wait_time = 0.35
	_footstep_timer.one_shot = false
	_footstep_timer.timeout.connect(_play_footstep)
	add_child(_footstep_timer)

	_footstep_player = AudioStreamPlayer2D.new()
	_footstep_player.bus = "SFX"
	add_child(_footstep_player)

	if footstep_sounds:
		_footstep_player.stream = footstep_sounds
	else:
		var randomizer := AudioStreamRandomizer.new()
		for i in range(1, 4):
			var path := "res://assets/audio/sfx/footstep_0%d.wav" % i
			var stream: AudioStream = load(path)
			if stream:
				randomizer.add_stream(i - 1, stream)
		_footstep_player.stream = randomizer

	EventBus.input_lock_changed.connect(_on_input_lock_changed)


func _physics_process(_delta: float) -> void:
	if _input_locked:
		velocity = Vector2.ZERO
		_footstep_timer.stop()
		return

	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if input != Vector2.ZERO:
		input = input.normalized()
		var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
		velocity = input * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if velocity != Vector2.ZERO:
		if _footstep_timer.is_stopped():
			_footstep_timer.start()
	else:
		_footstep_timer.stop()


func _unhandled_input(event: InputEvent) -> void:
	if _input_locked:
		return
	if event.is_action_pressed("interact") and _current_interactable != null:
		EventBus.interaction_triggered.emit(_current_interactable)


func set_interactable(node: Node) -> void:
	_current_interactable = node
	prompt_label.text = node.interaction_label if "interaction_label" in node else "Press E"
	prompt_label.visible = true
	# Also update HUD if available
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_prompt(prompt_label.text)


func clear_interactable() -> void:
	_current_interactable = null
	prompt_label.visible = false
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide_prompt()


func _on_input_lock_changed(locked: bool) -> void:
	_input_locked = locked
	if locked:
		velocity = Vector2.ZERO
		prompt_label.visible = false


func _play_footstep() -> void:
	if _footstep_player.stream:
		_footstep_player.play()
