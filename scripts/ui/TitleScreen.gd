extends Control

@onready var title_label: Label = $VBox/TitleLabel
@onready var subtitle_label: Label = $VBox/SubtitleLabel
@onready var start_button: Button = $VBox/StartButton
@onready var quit_button: Button = $VBox/QuitButton
@onready var bg: ColorRect = $BG
@onready var neon_overlay: ColorRect = $NeonOverlay

var _time: float = 0.0


func _ready() -> void:
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)
	start_button.grab_focus()


func _process(delta: float) -> void:
	_time += delta
	# Pulsing neon glow effect
	var pulse := (sin(_time * 2.0) + 1.0) * 0.5
	neon_overlay.modulate.a = lerp(0.03, 0.12, pulse)


func _on_start() -> void:
	GameState.reset()
	SceneManager.change_scene("res://scenes/world/World.tscn")


func _on_quit() -> void:
	get_tree().quit()
