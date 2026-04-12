extends "res://scripts/world/Interactable.gd"

@export var locked_message: String = "Access denied. Terminal authorization required."
@export var interaction_sfx: AudioStream

var _open: bool = false


func _ready() -> void:
	super._ready()
	interaction_label = "Press E to use door"


func interact() -> void:
	if interaction_sfx:
		AudioManager.play_sfx(interaction_sfx)

	if _open:
		EventBus.prop_interaction_completed.emit("locked_door", {"message": "The door is already open."})
		return

	if not GameState.terminal_activated:
		# Shake effect
		var tween := create_tween()
		var original_pos: Vector2 = $Sprite2D.position
		tween.tween_property($Sprite2D, "position", original_pos + Vector2(2, 0), 0.05)
		tween.tween_property($Sprite2D, "position", original_pos + Vector2(-2, 0), 0.05)
		tween.tween_property($Sprite2D, "position", original_pos, 0.05)
		tween.set_loops(2)
		EventBus.prop_interaction_completed.emit("locked_door", {"message": locked_message})
		return

	_open = true
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.modulate = Color(0.35, 0.95, 0.62)
	GameState.unlock_door()
