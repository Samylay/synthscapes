class_name DialogueModels

enum PortraitSide { LEFT, RIGHT }


class DialogueChoice:
	var text: String
	var next_node_id: String
	var end_conversation: bool
	var on_selected: Callable

	func _init(p_text: String, p_next_node_id: String = "", p_end_conversation: bool = false, p_on_selected: Callable = Callable()) -> void:
		text = p_text
		next_node_id = p_next_node_id
		end_conversation = p_end_conversation
		on_selected = p_on_selected


class DialogueNode:
	var id: String
	var speaker: String
	var text: String
	var portrait_side: PortraitSide
	var next_node_id: String
	var on_completed: Callable
	var choices: Array  # Array of DialogueChoice

	func _init(
		p_id: String,
		p_speaker: String,
		p_text: String,
		p_portrait_side: PortraitSide = PortraitSide.LEFT,
		p_next_node_id: String = "",
		p_on_completed: Callable = Callable(),
		p_choices: Array = []
	) -> void:
		id = p_id
		speaker = p_speaker
		text = p_text
		portrait_side = p_portrait_side
		next_node_id = p_next_node_id
		on_completed = p_on_completed
		choices = p_choices
