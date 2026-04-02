extends Node

# Pool of SFX players for overlapping sounds
const SFX_POOL_SIZE := 6
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0

# Two music players for crossfading
var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _active_music: AudioStreamPlayer

# Loaded sound effects — populated from audio/sfx/ on startup.
# Keys = filename without extension (e.g. "jump", "coin_collect").
var _sfx_cache: Dictionary = {}

# Loaded music tracks — populated from audio/music/.
var _music_cache: Dictionary = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Build SFX player pool
	for i in range(SFX_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)

	# Music players
	_music_a = AudioStreamPlayer.new()
	_music_a.bus = "Music"
	add_child(_music_a)
	_music_b = AudioStreamPlayer.new()
	_music_b.bus = "Music"
	add_child(_music_b)
	_active_music = _music_a

	_load_audio_dir("res://audio/sfx", _sfx_cache)
	_load_audio_dir("res://audio/music", _music_cache)

func _load_audio_dir(path: String, cache: Dictionary):
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		# Skip .import sidecar files
		if not file.ends_with(".import") and not dir.current_is_dir():
			var stream = load(path + "/" + file)
			if stream is AudioStream:
				var key = file.get_basename()
				cache[key] = stream
		file = dir.get_next()

# --------------- SFX ---------------

func play_sfx(name: String, volume_db: float = 0.0):
	if global.sound_muted:
		return
	var stream = _sfx_cache.get(name)
	if not stream:
		return
	var player = _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE
	player.stream = stream
	player.volume_db = volume_db
	player.play()

# --------------- Music ---------------

func play_music(name: String, fade_duration: float = 1.0):
	var stream = _music_cache.get(name)
	if not stream:
		return
	# If already playing this track, skip
	if _active_music.stream == stream and _active_music.playing:
		return

	var incoming: AudioStreamPlayer
	if _active_music == _music_a:
		incoming = _music_b
	else:
		incoming = _music_a

	incoming.stream = stream
	incoming.volume_db = -40.0
	incoming.play()

	# Crossfade
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(_active_music, "volume_db", -40.0, fade_duration)
	tween.tween_property(incoming, "volume_db", 0.0, fade_duration)
	tween.set_parallel(false)
	tween.tween_callback(func():
		_active_music.stop()
		_active_music = incoming
	)

func stop_music(fade_duration: float = 1.0):
	var tween = get_tree().create_tween()
	tween.tween_property(_active_music, "volume_db", -40.0, fade_duration)
	tween.tween_callback(_active_music.stop)
