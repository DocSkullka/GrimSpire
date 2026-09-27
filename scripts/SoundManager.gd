extends Node

var audio_players: Array[AudioStreamPlayer] = []
var current_player_idx: int = 0

var sfx_slash: AudioStreamWAV
var sfx_hit: AudioStreamWAV
var sfx_crit: AudioStreamWAV
var sfx_coin: AudioStreamWAV
var sfx_equip: AudioStreamWAV
var sfx_death: AudioStreamWAV
var sfx_click: AudioStreamWAV

func _init():
	_create_sfx()

func _ready():
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		audio_players.append(p)

func _create_sfx():
	sfx_slash = _generate_noise_sweep(0.12, 1200.0, 300.0, 0.4)
	sfx_hit = _generate_tone_decay(0.18, 120.0, 40.0, 0.7)
	sfx_crit = _generate_two_tone(0.25, 580.0, 1160.0, 0.6)
	sfx_coin = _generate_two_tone(0.18, 880.0, 1320.0, 0.4)
	sfx_equip = _generate_tone_decay(0.15, 260.0, 130.0, 0.5)
	sfx_death = _generate_descending_drone(0.8, 180.0, 40.0, 0.6)
	sfx_click = _generate_tone_decay(0.04, 800.0, 400.0, 0.3)

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

func _play(stream: AudioStreamWAV):
	if audio_players.is_empty():
		return
	var player = audio_players[current_player_idx]
	current_player_idx = (current_player_idx + 1) % audio_players.size()
	player.stream = stream
	player.play()

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
