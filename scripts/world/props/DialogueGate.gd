extends Node2D

@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	EventBus.dialogue_resolved_changed.connect(_unlock)
	if GameState.dialogue_resolved:
		_unlock()


func _unlock() -> void:
	collision.set_deferred("disabled", true)
	if sprite:
		sprite.modulate = Color(0.4, 0.92, 0.56)
