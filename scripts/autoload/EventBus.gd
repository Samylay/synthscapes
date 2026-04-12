extends Node

# World state signals
signal world_flag_changed(flag_name: String, value: Variant)

# Interaction signals
signal interaction_triggered(interactable: Node)

# Scene transition signals
signal scene_change_requested(scene_path: String)

# District zone signals
signal resolution_zone_entered()

# Prop interaction signals
signal prop_interaction_completed(prop_name: String, prop_data: Dictionary)

# HUD signals (migrated from Unity GameSession events)
signal objective_changed(objective: String)
signal feedback_requested(message: String)
signal dialogue_resolved_changed()

# Dialogue signals
signal dialogue_started()
signal dialogue_ended()

# Input lock
signal input_lock_changed(locked: bool)
