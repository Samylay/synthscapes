extends Area2D

enum ExitRequirement { NONE, DOOR_UNLOCKED, DIALOGUE_RESOLVED }

@export var next_scene_path: String = ""
@export var requirement: ExitRequirement = ExitRequirement.NONE


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	if not _requirement_met():
		return

	GameState.complete_demo()

	if not next_scene_path.is_empty():
		SceneManager.change_scene(next_scene_path)


func _requirement_met() -> bool:
	match requirement:
		ExitRequirement.NONE:
			return true
		ExitRequirement.DOOR_UNLOCKED:
			return GameState.door_unlocked
		ExitRequirement.DIALOGUE_RESOLVED:
			return GameState.dialogue_resolved
	return false
