extends "res://scripts/world/Interactable.gd"

@export var terminal_text: String = "SYSTEM LOG: Cipher v7.2.1 -- All citizens accounted for."
@export var flag_on_interact: String = "terminal_accessed"
@export var interaction_sfx: AudioStream

var _has_been_read: bool = false


func _ready() -> void:
	super._ready()
	interaction_label = "Press E to restore access"
	_has_been_read = GameState.get_flag(flag_on_interact, false)
	if _has_been_read:
		$Sprite2D.modulate = Color(0.55, 1.0, 0.72)


func interact() -> void:
	if interaction_sfx:
		AudioManager.play_sfx(interaction_sfx)
	if not _has_been_read:
		GameState.set_flag(flag_on_interact, true)
		_has_been_read = true
		$Sprite2D.modulate = Color(0.55, 1.0, 0.72)
		GameState.activate_terminal()
	EventBus.prop_interaction_completed.emit("terminal", {"message": terminal_text})
