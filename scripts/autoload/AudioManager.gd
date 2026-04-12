extends Node

const NUM_SFX_PLAYERS := 8

var _music_player: AudioStreamPlayer
var _ambience_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.bus = "Ambience"
	add_child(_ambience_player)

	for i in NUM_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)


func play_music(stream: AudioStream, from_position: float = 0.0) -> void:
	if _music_player.stream == stream and _music_player.playing:
		return  # Already playing this track
	_music_player.stream = stream
	_music_player.play(from_position)


func stop_music() -> void:
	_music_player.stop()


func play_sfx(stream: AudioStream) -> void:
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	# All players busy -- oldest one will finish naturally


func play_ambience(stream: AudioStream) -> void:
	if _ambience_player.stream == stream and _ambience_player.playing:
		return
	_ambience_player.stream = stream
	_ambience_player.play()


func stop_ambience() -> void:
	_ambience_player.stop()
