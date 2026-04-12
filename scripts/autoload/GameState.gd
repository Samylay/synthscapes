extends Node

# Tracks ending alignment scores
var scores := {
	"liberation": 0,
	"freedom_fighter": 0,
	"subjugation": 0,
	"cipher_betrayal": 0,
	"player_betrayal": 0,
}

# Tracks world state flags for environment mutations
var world_flags: Dictionary = {}

# Session state (migrated from Unity GameSession)
var terminal_activated: bool = false
var door_unlocked: bool = false
var demo_complete: bool = false
var dialogue_resolved: bool = false
var current_objective: String = ""


func add_score(ending: String, amount: int) -> void:
	if ending in scores:
		scores[ending] += amount


func get_dominant_ending() -> String:
	return scores.keys().reduce(func(a, b): return a if scores[a] >= scores[b] else b)


func set_flag(flag_name: String, value: Variant) -> void:
	world_flags[flag_name] = value
	EventBus.world_flag_changed.emit(flag_name, value)


func get_flag(flag_name: String, default: Variant = null) -> Variant:
	return world_flags.get(flag_name, default)


func has_flag(flag_name: String) -> bool:
	return flag_name in world_flags


func reset() -> void:
	for key in scores:
		scores[key] = 0
	world_flags.clear()
	terminal_activated = false
	door_unlocked = false
	demo_complete = false
	dialogue_resolved = false
	current_objective = "Reach the terminal and restore door access."
	EventBus.objective_changed.emit(current_objective)


func reset_dialogue_challenge() -> void:
	terminal_activated = false
	door_unlocked = false
	demo_complete = false
	dialogue_resolved = false
	current_objective = "Speak to the archivist and answer correctly."
	EventBus.objective_changed.emit(current_objective)


func activate_terminal() -> void:
	if terminal_activated:
		EventBus.feedback_requested.emit("The terminal is already online.")
		return
	terminal_activated = true
	current_objective = "Use the unlocked eastern door."
	EventBus.objective_changed.emit(current_objective)
	EventBus.feedback_requested.emit("Access restored. Eastern door unlocked.")


func unlock_door() -> void:
	if door_unlocked:
		return
	door_unlocked = true
	EventBus.feedback_requested.emit("Door unlocked.")


func complete_demo() -> void:
	if demo_complete:
		return
	demo_complete = true
	current_objective = "Slice complete."
	EventBus.objective_changed.emit(current_objective)
	EventBus.feedback_requested.emit("Demo complete. You escaped the room.")


func resolve_dialogue() -> void:
	if dialogue_resolved:
		return
	dialogue_resolved = true
	current_objective = "The archivist opened the gate. Leave the chamber."
	EventBus.objective_changed.emit(current_objective)
	EventBus.feedback_requested.emit("Correct answer. The gate opens.")
	EventBus.dialogue_resolved_changed.emit()
