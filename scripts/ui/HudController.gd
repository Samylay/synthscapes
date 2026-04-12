extends CanvasLayer

@onready var objective_label: Label = $ObjectiveLabel
@onready var prompt_label: Label = $PromptLabel
@onready var feedback_label: Label = $FeedbackLabel
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/VBox/SpeakerLabel
@onready var dialogue_label: Label = $DialoguePanel/VBox/DialogueLabel
@onready var choices_label: Label = $DialoguePanel/VBox/ChoicesLabel
@onready var hint_label: Label = $DialoguePanel/VBox/HintLabel

var _feedback_tween: Tween


func _ready() -> void:
	EventBus.objective_changed.connect(_on_objective_changed)
	EventBus.feedback_requested.connect(_on_feedback_requested)
	prompt_label.visible = false
	feedback_label.visible = false
	dialogue_panel.visible = false


func _on_objective_changed(objective: String) -> void:
	objective_label.text = objective


func _on_feedback_requested(message: String) -> void:
	show_feedback(message)


func show_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = true


func hide_prompt() -> void:
	prompt_label.visible = false


func show_feedback(message: String) -> void:
	if _feedback_tween:
		_feedback_tween.kill()
	feedback_label.text = message
	feedback_label.visible = true
	feedback_label.modulate.a = 1.0
	_feedback_tween = create_tween()
	_feedback_tween.tween_interval(2.5)
	_feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.3)
	_feedback_tween.tween_callback(feedback_label.set.bind("visible", false))


func show_dialogue_panel() -> void:
	dialogue_panel.visible = true
	dialogue_panel.modulate.a = 0.0
	dialogue_panel.scale = Vector2(0.92, 0.92)
	var tween := create_tween().set_parallel()
	tween.tween_property(dialogue_panel, "modulate:a", 1.0, 0.18)
	tween.tween_property(dialogue_panel, "scale", Vector2.ONE, 0.18)


func hide_dialogue_panel() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(dialogue_panel, "modulate:a", 0.0, 0.18)
	tween.tween_property(dialogue_panel, "scale", Vector2(0.92, 0.92), 0.18)
	tween.chain().tween_callback(dialogue_panel.set.bind("visible", false))


func set_speaker(speaker: String) -> void:
	speaker_label.text = speaker


func set_dialogue_text(text: String) -> void:
	dialogue_label.text = text


func set_choices(choice_texts: Array) -> void:
	if choice_texts.is_empty():
		choices_label.visible = false
		return
	var lines := PackedStringArray()
	for i in choice_texts.size():
		lines.append("%d. %s" % [i + 1, choice_texts[i]])
	choices_label.text = "\n".join(lines)
	choices_label.visible = true


func set_hint(hint: String) -> void:
	hint_label.text = hint
