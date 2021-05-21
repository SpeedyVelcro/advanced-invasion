# GlobalMusic.gd

extends Node

var music = {
	"download" : "res://Music/Download.ogg",
	"militia" : "res://Music/Militia.ogg",
	"invasion" : "res://Music/Invasion.ogg",
	"meager" : "res://Music/Meager.ogg",
	"firefly" : "res://Music/Firefly.ogg",
	"brash" : "res://Music/Brash.ogg",
	"anxiety" : "res://Music/Anxiety.ogg",
	"sanctuary" : "res://Music/Sanctuary.ogg",
	"petra" : "res://Music/Petra.ogg",
	"dynamite" : "res://Music/Dynamite.ogg",
	"deathbed" : "res://Music/Deathbed.ogg",
	"favour" : "res://Music/Favour.ogg",
	"brash_fakeout" : "res://Music/BrashFakeout.ogg",
	"brash_intro" : "res://Music/BrashIntro.ogg",
	"brash_no_intro" : "res://Music/BrashNoIntro.ogg"
}
var next_music_id
var next_from_position
var music_queued = false
var fading_out = false
var current_music_id = ""
const PAUSE_VOLUME_LINEAR = 0.1

func play(music_id, fadeout_sec = 0.0, from_position = 0.0, force = false):
	if music_id == current_music_id and not force:
		return
	if not GameStatus.is_soundtrack_unlocked(music_id):
		GameStatus.set_soundtrack_unlocked(music_id, true)
		GameStatus.save()
	$VolumeTween.stop_all()
	if fadeout_sec == 0 or not $AudioStreamPlayer.is_playing():
		current_music_id = music_id
		$AudioStreamPlayer.stop()
		$AudioStreamPlayer.stream = load(music[music_id])
		$AudioStreamPlayer.volume_db = 0
		$AudioStreamPlayer.play(from_position)
		if from_position != 0:
			$AudioStreamPlayer.volume_db = -80
			$VolumeTween.interpolate_property($AudioStreamPlayer, "volume_db", null, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$VolumeTween.start()
		print("Playing music " + music_id)
	else:
		next_music_id = music_id
		next_from_position = from_position
		fading_out = true
		music_queued = true
		$VolumeTween.interpolate_property($AudioStreamPlayer, "volume_db", null, -80, fadeout_sec, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$VolumeTween.start()
		print("Playing music " + music_id + " after fadeout")

func stop(fadeout_sec = 1.0):
	current_music_id = ""
	if fadeout_sec == 0:
		$AudioStreamPlayer.stop()
	else:
		fading_out = true
		$VolumeTween.interpolate_property($AudioStreamPlayer, "volume_db", null, -80, fadeout_sec, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$VolumeTween.start()

func adjust_volume_linear(volume, time_sec):
	if time_sec == 0:
		$AudioStreamPlayer.set_volume_db(linear2db(volume))
	else:
		$VolumeTween.interpolate_property($AudioStreamPlayer, "volume_db", null, linear2db(volume), time_sec, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$VolumeTween.start()

func _on_VolumeTween_tween_completed(object, key):
	if fading_out:
		$AudioStreamPlayer.stop()
		fading_out = false
		if music_queued:
			current_music_id = next_music_id
			$AudioStreamPlayer.stream = load(music[next_music_id])
			$AudioStreamPlayer.volume_db = 0
			$AudioStreamPlayer.play(next_from_position)
			music_queued = false
			if next_from_position != 0:
				$AudioStreamPlayer.volume_db = -80
				$VolumeTween.interpolate_property($AudioStreamPlayer, "volume_db", null, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$VolumeTween.start()

func _on_AudioStreamPlayer_finished():
	current_music_id = ""

# Getters and setters
func get_current_music_id():
	return current_music_id

func is_playing():
	return $AudioStreamPlayer.is_playing()
