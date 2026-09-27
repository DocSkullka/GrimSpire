extends Node

var audio_players: Array[AudioStreamPlayer] = []
var current_player_idx: int = 0
var music_player: AudioStreamPlayer = null

var master_volume: float = 0.8
var sfx_volume: float = 0.8
var music_volume: float = 0.5

# Sound Effects (16-bit High Fidelity AudioStreamWAV)
var sfx_slash: AudioStreamWAV
var sfx_hit: AudioStreamWAV
var sfx_crit: AudioStreamWAV
var sfx_coin: AudioStreamWAV
var sfx_equip: AudioStreamWAV
var sfx_death: AudioStreamWAV
var sfx_click: AudioStreamWAV
var sfx_step: AudioStreamWAV
var sfx_block: AudioStreamWAV
var sfx_soul: AudioStreamWAV
var sfx_room_clear: AudioStreamWAV

# New Rebirth Sound Effects
var sfx_lockpick: AudioStreamWAV
var sfx_gate: AudioStreamWAV
var sfx_elevator: AudioStreamWAV
var sfx_taunt: AudioStreamWAV
var sfx_heal: AudioStreamWAV
var sfx_backstab: AudioStreamWAV
var sfx_fusion: AudioStreamWAV

# Dark Medieval Lo-Fi Music Loops
var bgm_camp: AudioStreamWAV
var bgm_combat: AudioStreamWAV
var current_music_mode: String = ""

func _init():
	_create_sfx()
	_create_music_tracks()

func _ready():
	for i in range(20):
		var p = AudioStreamPlayer.new()
		add_child(p)
		audio_players.append(p)
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	play_camp_theme()

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

func play_camp_theme():
	if current_music_mode == "camp" and music_player.playing:
		return
	current_music_mode = "camp"
	if music_player != null and bgm_camp != null:
		music_player.stream = bgm_camp
		_update_music_volume()
		music_player.play()

func play_combat_theme():
	if current_music_mode == "combat" and music_player.playing:
		return
	current_music_mode = "combat"
	if music_player != null and bgm_combat != null:
		music_player.stream = bgm_combat
		_update_music_volume()
		music_player.play()

# Standard and Rebirth SFX playback
func play_slash(): _play(sfx_slash)
func play_hit(): _play(sfx_hit)
func play_crit(): _play(sfx_crit)
func play_coin(): _play(sfx_coin)
func play_equip(): _play(sfx_equip)
func play_death(): _play(sfx_death)
func play_click(): _play(sfx_click)
func play_step(): _play(sfx_step)
func play_block(): _play(sfx_block)
func play_soul(): _play(sfx_soul)
func play_room_clear(): _play(sfx_room_clear)
func play_test_sound(): _play(sfx_coin)

func play_lockpick(): _play(sfx_lockpick)
func play_gate(): _play(sfx_gate)
func play_elevator(): _play(sfx_elevator)
func play_taunt(): _play(sfx_taunt)
func play_heal(): _play(sfx_heal)
func play_backstab(): _play(sfx_backstab)
func play_fusion(): _play(sfx_fusion)

func _play(stream: AudioStreamWAV):
	if audio_players.is_empty() or stream == null:
		return
	var player = audio_players[current_player_idx]
	current_player_idx = (current_player_idx + 1) % audio_players.size()
	player.stream = stream
	player.volume_db = _calc_db(sfx_volume * master_volume)
	player.play()

# =============================================================================
# SYNTHESIS: DARK MEDIEVAL LO-FI / DUNGEON SYNTH ENGINE
# Eliminates all 55Hz buzzing drones. Clean, warm, atmospheric 16-bit audio.
# =============================================================================
func _create_sfx():
	sfx_slash = _generate_blade_slash(0.14)
	sfx_hit = _generate_punch_impact(0.18)
	sfx_crit = _generate_crystal_crit(0.32)
	sfx_coin = _generate_coin_jingle(0.2)
	sfx_equip = _generate_armor_equip(0.18)
	sfx_death = _generate_death_chime(0.9)
	sfx_click = _generate_ui_click(0.04)
	sfx_step = _generate_stone_footstep(0.08)
	sfx_block = _generate_shield_clang(0.22)
	sfx_soul = _generate_soul_cleave_burst(0.4)
	sfx_room_clear = _generate_victory_fanfare(0.45)
	
	sfx_lockpick = _generate_lockpick_tumbler(0.25)
	sfx_gate = _generate_gate_chains(0.65)
	sfx_elevator = _generate_elevator_hum(0.6)
	sfx_taunt = _generate_taunt_warcry(0.35)
	sfx_heal = _generate_heal_chime(0.4)
	sfx_backstab = _generate_backstab_strike(0.26)
	sfx_fusion = _generate_forge_fusion(0.55)

func _create_music_tracks():
	bgm_camp = _generate_dark_medieval_camp_lofi(8.0)
	bgm_combat = _generate_spire_ascent_combat_lofi(8.0)

# Helper: allocate 16-bit WAV
func _create_wav(samples: int, mix_rate: int = 22050, loop: bool = false) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	if loop:
		wav.loop_begin = 0
		wav.loop_end = samples
	return wav

# 1. Dark Medieval Lo-Fi: Camp / Sanctuary (Peaceful Lute Arpeggios & Vinyl Ambiance)
func _generate_dark_medieval_camp_lofi(duration: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(duration * rate)
	var wav = _create_wav(samples, rate, true)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)

	# Lute Notes (D Minor / D Dorian arpeggio pattern: D3=146.8Hz, F3=174.6Hz, A3=220Hz, D4=293.7Hz, C4=261.6Hz)
	var notes = [146.8, 220.0, 293.7, 349.2, 261.6, 220.0, 174.6, 220.0]
	var note_dur = duration / float(notes.size())

	for i in range(samples):
		var t = float(i) / float(rate)
		var note_idx = int(t / note_dur) % notes.size()
		var note_t = fmod(t, note_dur)
		var freq = notes[note_idx]

		# Acoustic Lute Pluck Envelope (Sharp attack, exponential decay with warm harmonics)
		var env = exp(-note_t * 4.5)
		var harmonic1 = sin(note_t * freq * TAU)
		var harmonic2 = sin(note_t * freq * 2.0 * TAU) * 0.4 * exp(-note_t * 7.0)
		var harmonic3 = sin(note_t * freq * 3.0 * TAU) * 0.15 * exp(-note_t * 10.0)
		var lute = (harmonic1 + harmonic2 + harmonic3) * env * 0.42

		# Warm Atmosphere Pad (Gentle fifths, soft swelling envelope)
		var pad_freq1 = 146.8
		var pad_freq2 = 220.0
		var pad_env = 0.5 + 0.2 * sin(t * 0.5 * TAU)
		var pad = (sin(t * pad_freq1 * TAU) * 0.15 + sin(t * pad_freq2 * TAU) * 0.1) * pad_env

		# Soft Vinyl Dust & Hearth Fire Crackle (Subtle, non-droning texture)
		var crackle = 0.0
		if randf() < 0.003:
			crackle = (randf() * 2.0 - 1.0) * 0.12

		var total = (lute + pad + crackle) * 0.85
		var sample_val = int(clamp(total * 32767.0, -32767.0, 32767.0))
		bytes.encode_s16(i * 2, sample_val)

	wav.data = bytes
	return wav

# 2. Spire Ascent / Combat Theme: Dark Medieval Lo-Fi Beat (70 BPM Downtempo)
func _generate_spire_ascent_combat_lofi(duration: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(duration * rate)
	var wav = _create_wav(samples, rate, true)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)

	# 70 BPM: beat length = 60 / 70 = 0.857 seconds. 8-beat bar in ~6.85 sec loop
	var beat_len = 60.0 / 70.0
	var notes = [146.8, 174.6, 220.0, 261.6, 293.7, 261.6, 220.0, 196.0]

	for i in range(samples):
		var t = float(i) / float(rate)
		var beat_pos = fmod(t, beat_len)
		var beat_num = int(t / beat_len)

		# 1. Soft Round Lo-Fi Kick (on beats 0, 2, 4, 6)
		var kick = 0.0
		if beat_num % 2 == 0 and beat_pos < 0.22:
			var kick_env = exp(-beat_pos * 18.0)
			var kick_pitch = lerp(85.0, 42.0, beat_pos / 0.22)
			kick = sin(beat_pos * kick_pitch * TAU) * kick_env * 0.45

		# 2. Wooden Rimshot / Snare (on beats 1, 3, 5, 7)
		var snare = 0.0
		if beat_num % 2 == 1 and beat_pos < 0.15:
			var snare_env = exp(-beat_pos * 24.0)
			var noise = (randf() * 2.0 - 1.0) * 0.25
			var wood_body = sin(beat_pos * 280.0 * TAU) * 0.35
			snare = (noise + wood_body) * snare_env * 0.4

		# 3. Subtle Shaker / Vinyl Dust (every 8th note)
		var shaker = 0.0
		var sub_beat = fmod(t, beat_len * 0.5)
		if sub_beat < 0.04:
			shaker = (randf() * 2.0 - 1.0) * exp(-sub_beat * 70.0) * 0.08

		# 4. Dark Medieval Melody (Lute / Dark Harpsichord tone)
		var note_idx = int(t / (beat_len * 0.5)) % notes.size()
		var note_t = fmod(t, beat_len * 0.5)
		var freq = notes[note_idx]
		var mel_env = exp(-note_t * 5.0)
		var melody = (sin(note_t * freq * TAU) * 0.3 + sin(note_t * freq * 2.0 * TAU) * 0.12) * mel_env

		# 5. Warm Analog Sub-Bass (Deep round sine root, zero buzz)
		var bass_freq = 73.4 # D2
		if beat_num % 4 >= 2:
			bass_freq = 87.3 # F2
		var bass = sin(t * bass_freq * TAU) * 0.22

		var mix = (kick + snare + shaker + melody + bass) * 0.85
		var sample_val = int(clamp(mix * 32767.0, -32767.0, 32767.0))
		bytes.encode_s16(i * 2, sample_val)

	wav.data = bytes
	return wav

# =============================================================================
# PROCEDURAL SFX GENERATORS (Clean 16-bit Studio Quality)
# =============================================================================
func _generate_blade_slash(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var freq = lerp(1800.0, 400.0, t * t)
		var tone = sin(float(i) / rate * freq * TAU) * 0.4
		var noise = (randf() * 2.0 - 1.0) * 0.6
		var env = sin(t * PI) * exp(-t * 3.0)
		var val = (tone + noise) * env * 0.6
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_punch_impact(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var freq = lerp(160.0, 50.0, t)
		var val = sin(float(i) / rate * freq * TAU) * exp(-t * 12.0) * 0.7
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_crystal_crit(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var v1 = sin(float(i) / rate * 640.0 * TAU) * exp(-t * 6.0)
		var v2 = sin(float(i) / rate * 1280.0 * TAU) * exp(-t * 9.0) * 0.5
		var val = (v1 + v2) * 0.55
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_coin_jingle(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var f = 987.7 if t < 0.4 else 1318.5 # B5 -> E6
		var val = sin(float(i) / rate * f * TAU) * exp(-fmod(t, 0.4) * 8.0) * 0.45
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_armor_equip(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var freq = lerp(420.0, 180.0, t)
		var clank = (sin(float(i) / rate * freq * TAU) + (randf() * 2.0 - 1.0) * 0.3) * exp(-t * 10.0)
		bytes.encode_s16(i * 2, int(clamp(clank * 0.5 * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_death_chime(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var bell = sin(float(i) / rate * 220.0 * TAU) * exp(-t * 2.5) * 0.4
		var low = sin(float(i) / rate * 110.0 * TAU) * exp(-t * 1.8) * 0.3
		var val = bell + low
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_ui_click(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var val = sin(float(i) / rate * 950.0 * TAU) * (1.0 - t) * 0.35
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_stone_footstep(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var stone_thud = sin(float(i) / rate * 120.0 * TAU) * exp(-t * 28.0) * 0.4
		var scuff = (randf() * 2.0 - 1.0) * exp(-t * 35.0) * 0.2
		var val = (stone_thud + scuff) * 0.5
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_shield_clang(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var metal1 = sin(float(i) / rate * 880.0 * TAU) * exp(-t * 14.0) * 0.4
		var metal2 = sin(float(i) / rate * 1450.0 * TAU) * exp(-t * 20.0) * 0.35
		var spark = (randf() * 2.0 - 1.0) * exp(-t * 25.0) * 0.15
		var val = (metal1 + metal2 + spark) * 0.65
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_soul_cleave_burst(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var sweep = sin(float(i) / rate * lerp(220.0, 880.0, t) * TAU) * exp(-t * 4.0) * 0.45
		var boom = sin(float(i) / rate * 75.0 * TAU) * exp(-t * 8.0) * 0.55
		var val = (sweep + boom) * 0.6
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_victory_fanfare(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var f = 523.25 if t < 0.25 else 783.99 # C5 -> G5
		var val = sin(float(i) / rate * f * TAU) * exp(-fmod(t, 0.25) * 6.0) * 0.5
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_lockpick_tumbler(dur: float) -> AudioStreamWAV:
	# Click-clack realistic mechanical lockpicking tumbler sound
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var click1 = 0.0
		var click2 = 0.0
		if t < 0.12:
			click1 = sin(t * 1200.0 * TAU) * exp(-t * 40.0) * 0.4
		elif t >= 0.12 and t < 0.24:
			var t2 = t - 0.12
			click2 = sin(t2 * 1850.0 * TAU) * exp(-t2 * 45.0) * 0.55
		var spring = (randf() * 2.0 - 1.0) * exp(-t * 20.0) * 0.12
		var val = (click1 + click2 + spring) * 0.7
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_gate_chains(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var rattle = (randf() * 2.0 - 1.0) * 0.35 * exp(-t * 2.5)
		var clang = sin(float(i) / rate * 320.0 * TAU) * exp(-fmod(t, 0.15) * 15.0) * 0.35
		var val = (rattle + clang) * 0.6
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_elevator_hum(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var runic_shimmer = sin(float(i) / rate * 587.3 * TAU) * (0.6 + 0.4 * sin(t * 8.0 * TAU)) * 0.25
		var stone_rumble = sin(float(i) / rate * 95.0 * TAU) * exp(-t * 1.5) * 0.35
		var val = (runic_shimmer + stone_rumble) * 0.65
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_taunt_warcry(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var freq = lerp(130.0, 95.0, t)
		var roar = (sin(float(i) / rate * freq * TAU) + (randf() * 2.0 - 1.0) * 0.2) * exp(-t * 5.0) * 0.6
		bytes.encode_s16(i * 2, int(clamp(roar * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_heal_chime(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var c1 = sin(float(i) / rate * 523.25 * TAU) * exp(-t * 4.0) * 0.3
		var c2 = sin(float(i) / rate * 659.25 * TAU) * exp(-t * 4.0) * 0.3
		var c3 = sin(float(i) / rate * 783.99 * TAU) * exp(-t * 3.5) * 0.25
		var val = (c1 + c2 + c3) * 0.6
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_backstab_strike(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var swoosh = sin(float(i) / rate * lerp(2400.0, 600.0, t * t) * TAU) * (randf() * 0.5 + 0.5) * exp(-t * 12.0) * 0.4
		var stab = sin(float(i) / rate * 140.0 * TAU) * exp(-t * 8.0) * 0.45
		var val = (swoosh + stab) * 0.65
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav

func _generate_forge_fusion(dur: float) -> AudioStreamWAV:
	var rate = 22050
	var samples = int(dur * rate)
	var wav = _create_wav(samples, rate)
	var bytes = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / float(samples)
		var anvil = sin(float(i) / rate * 1174.6 * TAU) * exp(-t * 7.0) * 0.4
		var gong = sin(float(i) / rate * 440.0 * TAU) * exp(-t * 3.5) * 0.35
		var sparks = (randf() * 2.0 - 1.0) * exp(-t * 18.0) * 0.15
		var val = (anvil + gong + sparks) * 0.65
		bytes.encode_s16(i * 2, int(clamp(val * 32767.0, -32767.0, 32767.0)))
	wav.data = bytes
	return wav
