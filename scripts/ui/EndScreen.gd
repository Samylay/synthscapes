extends Control

@onready var title_label: Label = $VBox/TitleLabel
@onready var ending_label: Label = $VBox/EndingLabel
@onready var score_label: Label = $VBox/ScoreLabel
@onready var menu_button: Button = $VBox/MenuButton
@onready var quit_button: Button = $VBox/QuitButton

var _time: float = 0.0


func _ready() -> void:
	menu_button.pressed.connect(_on_menu)
	quit_button.pressed.connect(_on_quit)
	menu_button.grab_focus()

	var dominant := GameState.get_dominant_ending()
	var endings := {
		"liberation": "Liberation - You freed the city from Cipher's grip.",
		"freedom_fighter": "Freedom Fighter - You became a symbol of resistance.",
		"subjugation": "Subjugation - Cipher's control is absolute.",
		"cipher_betrayal": "Cipher's Betrayal - The AI turned on its own masters.",
		"player_betrayal": "Player's Betrayal - You chose power over freedom.",
	}
	ending_label.text = endings.get(dominant, "The story continues...")

	var total_score := 0
	for key in GameState.scores:
		total_score += GameState.scores[key]
	score_label.text = "Alignment Score: %d" % total_score


func _process(delta: float) -> void:
	_time += delta
	var pulse := (sin(_time * 1.5) + 1.0) * 0.5
	title_label.modulate.a = lerp(0.6, 1.0, pulse)


func _on_menu() -> void:
	SceneManager.change_scene("res://scenes/ui/TitleScreen.tscn")


func _on_quit() -> void:
	get_tree().quit()
