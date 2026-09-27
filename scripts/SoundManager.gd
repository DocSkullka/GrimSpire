extends Node

var audio_players: Array[AudioStreamPlayer] = []
var current_player_idx: int = 0
var music_player: AudioStreamPlayer = null

var master_volume: float = 0.8
var sfx_volume: float = 0.8
var music_volume: float = 0.5

var sfx_slash: AudioStreamWAV
var sfx_hit: AudioStreamWAV
var sfx_crit: AudioStreamWAV
var sfx_coin: AudioStreamWAV
var sfx_equip: AudioStreamWAV
var sfx_death: AudioStreamWAV
var sfx_click: AudioStreamWAV
var bgm_ambient: AudioStreamWAV

func _init():
	_create_sfx()

func _ready():
	for i in range(12):
		var p = AudioStreamPlayer.new()
		add_child(p)
		audio_players.append(p)
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = bgm_ambient
	_update_music_volume()
	music_player.play()

func set_master_volume(val: float):
	master_volume = clamp(val, 0.0, 1.0)
	var db = _calc_db(master_volume)
	if AudioServer.get_bus_count() > 0:
		AudioServer.set_bus_volume_db(0, db)
		AudioServer.set_bus_mute(0, master_volume <= 0.005)
	_update_music_volume()

func set_sfx_volume(val: float):
	sfx_volume = clamp(val, 0.0, 1.0)

func set_music_volume(val: float):
	music_volume = clamp(val, 0.0, 1.0)
	_update_music_volume()

func _calc_db(linear_vol: float) -> float:
	if linear_vol <= 0.005:
		return -80.0
	return linear_to_db(clamp(linear_vol, 0.005, 1.0))

func _update_music_volume():
	if music_player != null:
		music_player.volume_db = _calc_db(music_volume * master_volume)

func play_slash():
	_play(sfx_slash)

func play_hit():
	_play(sfx_hit)

func play_crit():
	_play(sfx_crit)

func play_coin():
	_play(sfx_coin)

func play_equip():
	_play(sfx_equip)

func play_death():
	_play(sfx_death)

func play_click():
	_play(sfx_click)

func play_test_sound():
	_play(sfx_coin)

func _play(stream: AudioStreamWAV):
	if audio_players.is_empty() or stream == null:
		return
	var player = audio_players[current_player_idx]
	current_player_idx = (current_player_idx + 1) % audio_players.size()
	player.stream = stream
	player.volume_db = _calc_db(sfx_volume * master_volume)
	player.play()

func _create_sfx():
	sfx_slash = _generate_noise_sweep(0.12, 1200.0, 300.0, 0.45)
	sfx_hit = _generate_tone_decay(0.18, 120.0, 40.0, 0.7)
	sfx_crit = _generate_two_tone(0.25, 580.0, 1160.0, 0.6)
	sfx_coin = _generate_two_tone(0.18, 880.0, 1320.0, 0.45)
	sfx_equip = _generate_tone_decay(0.15, 260.0, 130.0, 0.5)
	sfx_death = _generate_descending_drone(0.8, 180.0, 40.0, 0.6)
	sfx_click = _generate_tone_decay(0.04, 800.0, 400.0, 0.35)
	bgm_ambient = _generate_dark_ambient_loop(4.0)

func _generate_dark_ambient_loop(duration: float) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples = int(duration * 22050.0)
	var bytes = PackedByteArray()
	for i in range(samples):
		var t = float(i) / 22050.0
		# Integer cycle harmonics for seamless loop:
		# 55Hz (220 cycles), 110Hz (440 cycles), 165Hz (660 cycles)
		var slow_pulse = 0.75 + 0.25 * sin(t * 0.25 * TAU)
		var slow_pulse2 = 0.8 + 0.2 * cos(t * 0.5 * TAU)
		var val1 = sin(t * 55.0 * TAU) * 0.45 * slow_pulse
		var val2 = sin(t * 110.0 * TAU) * 0.25 * slow_pulse2
		var val3 = sin(t * 165.0 * TAU) * 0.15
		var total = (val1 + val2 + val3) * 0.4
		var sample = int(clamp((total * 0.5 + 0.5) * 255.0, 0, 255))
		bytes.append(sample)
	wav.data = bytes
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = samples
	return wav

func _generate_tone_decay(duration: float, start_freq: float, end_freq: float, volume: float) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples = int(duration * 22050.0)
	var bytes = PackedByteArray()
	for i in range(samples):
		var t = float(i) / float(samples)
		var freq = lerp(start_freq, end_freq, t)
		var val = sin(float(i) / 22050.0 * freq * 2.0 * PI) * (1.0 - t) * volume
		var sample = int(clamp((val * 0.5 + 0.5) * 255.0, 0, 255))
		bytes.append(sample)
	wav.data = bytes
	return wav

func _generate_noise_sweep(duration: float, start_freq: float, end_freq: float, volume: float) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples = int(duration * 22050.0)
	var bytes = PackedByteArray()
	for i in range(samples):
		var t = float(i) / float(samples)
		var noise = (randf() * 2.0 - 1.0) * 0.5
		var freq = lerp(start_freq, end_freq, t)
		var tone = sin(float(i) / 22050.0 * freq * 2.0 * PI) * 0.5
		var val = (noise + tone) * (1.0 - t * t) * volume
		var sample = int(clamp((val * 0.5 + 0.5) * 255.0, 0, 255))
		bytes.append(sample)
	wav.data = bytes
	return wav

func _generate_two_tone(duration: float, freq1: float, freq2: float, volume: float) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples = int(duration * 22050.0)
	var bytes = PackedByteArray()
	for i in range(samples):
		var t = float(i) / float(samples)
		var f = freq1 if t < 0.5 else freq2
		var env = sin(t * PI) * volume
		var val = sin(float(i) / 22050.0 * f * 2.0 * PI) * env
		var sample = int(clamp((val * 0.5 + 0.5) * 255.0, 0, 255))
		bytes.append(sample)
	wav.data = bytes
	return wav

func _generate_descending_drone(duration: float, start_freq: float, end_freq: float, volume: float) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var samples = int(duration * 22050.0)
	var bytes = PackedByteArray()
	for i in range(samples):
		var t = float(i) / float(samples)
		var freq = lerp(start_freq, end_freq, t)
		var env = exp(-t * 2.5) * volume
		var val = (sin(float(i) / 22050.0 * freq * 2.0 * PI) + 0.3 * sin(float(i) / 22050.0 * freq * 4.0 * PI)) * env
		var sample = int(clamp((val * 0.5 + 0.5) * 255.0, 0, 255))
		bytes.append(sample)
	wav.data = bytes
	return wav
