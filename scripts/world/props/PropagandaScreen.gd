# Interactable propaganda screen prop.
# Flashes red when interacted with and displays a propaganda message.
extends "res://scripts/world/Interactable.gd"

@export var message: String = "OBEY CIPHER. SAFETY IS COMPLIANCE."
@export var interaction_sfx: AudioStream


func _ready() -> void:
	super._ready()
	interaction_label = "Propaganda Screen"


func interact() -> void:
	# Flash effect: red tint then back to white, repeated 3 times
	var tween := create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 0.1)
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
	tween.set_loops(3)
	# Play interaction SFX through AudioManager
	if interaction_sfx:
		AudioManager.play_sfx(interaction_sfx)
	# Emit signal so feedback UI can display the message
	EventBus.prop_interaction_completed.emit("propaganda_screen", {"message": message})
