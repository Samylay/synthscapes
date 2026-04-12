extends Node

const CHAR_DELAY := 0.018
const WAIT_KEYS := {
	".": 0.28,
	",": 0.14,
	"!": 0.22,
	"?": 0.22,
}

var _active_npc: Node = null
var _current_node: DialogueModels.DialogueNode = null
var _is_typing: bool = false
var _skip_requested: bool = false
var _waiting_for_advance: bool = false
var _waiting_for_choice: bool = false
var _hud: Node = null


func _ready() -> void:
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if _active_npc == null or _hud == null:
		return

	if event.is_action_pressed("dialogue_advance"):
		if _is_typing:
			_skip_requested = true
			get_viewport().set_input_as_handled()
			return
		if _waiting_for_advance:
			_advance_node()
			get_viewport().set_input_as_handled()
			return

	if _waiting_for_choice:
		if event.is_action_pressed("choice_1"):
			_select_choice(0)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("choice_2"):
			_select_choice(1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("choice_3"):
			_select_choice(2)
			get_viewport().set_input_as_handled()


func start_conversation(npc: Node, hud: Node) -> void:
	if npc == null or hud == null:
		return
	if _active_npc != null:
		end_conversation()

	_active_npc = npc
	_hud = hud
	EventBus.input_lock_changed.emit(true)
	EventBus.dialogue_started.emit()
	_hud.hide_prompt()
	_hud.show_dialogue_panel()
	_show_node(npc.get_start_node())


func _show_node(node: DialogueModels.DialogueNode) -> void:
	if node == null:
		end_conversation()
		return

	_current_node = node
	_waiting_for_advance = false
	_waiting_for_choice = false
	_skip_requested = false

	_hud.set_speaker(node.speaker)
	_hud.set_dialogue_text("")
	_hud.set_choices([])
	_hud.set_hint("Press E / Space to skip")

	_type_text(node)


func _type_text(node: DialogueModels.DialogueNode) -> void:
	_is_typing = true
	var full_text: String = node.text if node.text else ""

	for i in full_text.length():
		if _skip_requested:
			_hud.set_dialogue_text(full_text)
			_skip_requested = false
			break
		_hud.set_dialogue_text(full_text.substr(0, i + 1))
		var ch := full_text[i]
		var delay: float = WAIT_KEYS.get(ch, CHAR_DELAY)
		await get_tree().create_timer(delay).timeout

	_hud.set_dialogue_text(full_text)
	_is_typing = false

	if node.choices.size() > 0:
		var labels: Array = []
		for choice in node.choices:
			labels.append(choice.text)
		_hud.set_choices(labels)
		_hud.set_hint("Choose with 1, 2 or 3")
		_waiting_for_choice = true
		return

	_hud.set_hint("Press E / Space to continue")
	_waiting_for_advance = true


func _advance_node() -> void:
	_waiting_for_advance = false
	if _current_node and _current_node.on_completed.is_valid():
		_current_node.on_completed.call()

	if _current_node == null:
		end_conversation()
		return

	if not _current_node.next_node_id.is_empty():
		_show_node(_active_npc.get_node_by_id(_current_node.next_node_id))
		return

	end_conversation()


func _select_choice(index: int) -> void:
	if _current_node == null or index < 0 or index >= _current_node.choices.size():
		return

	_waiting_for_choice = false
	var choice: DialogueModels.DialogueChoice = _current_node.choices[index]

	if choice.on_selected.is_valid():
		choice.on_selected.call()

	if not choice.next_node_id.is_empty():
		_show_node(_active_npc.get_node_by_id(choice.next_node_id))
		return

	end_conversation()


func end_conversation() -> void:
	_is_typing = false
	_skip_requested = false
	_waiting_for_advance = false
	_waiting_for_choice = false

	if _hud:
		_hud.hide_dialogue_panel()

	EventBus.input_lock_changed.emit(false)
	EventBus.dialogue_ended.emit()
	_active_npc = null
	_current_node = null
	_hud = null
