extends Node
## Old autoload before migration to SV Jukebox. It has been repurposed as an
## adapter for backwards-compatibility purposes.
##
## @deprecated: Use the SVJukebox autoload instead.

var _current_tween: Tween

## Play
##
## @deprecated: Use SVJukebox.play() instead.
func play(music_id, fadeout_sec = 0.0, from_position = 0.0, force = false):
	# Buckle up kiddo we're about to break contract in a pretty ugly way.
	if force and SVJukebox._current_id == music_id: # TODO: Instead of querying a private member, upstream a new method SVJukebox.get_playing_id() instead.
		SVJukebox._current_id = "" # TODO: Add an optional force flag in upstream SVJukebox.play() instead.
	
	if fadeout_sec > 0.0:
		SVJukebox.play(music_id, from_position, SVJukebox.TransitionType.FADE_OUT, fadeout_sec)
	else:
		SVJukebox.play(music_id, from_position, SVJukebox.TransitionType.INSTANT)

## Stop
##
## @deprecated: Use SVJukebox.stop() instead.
func stop(fadeout_sec = 1.0):
	if fadeout_sec > 0.0:
		SVJukebox.stop(SVJukebox.TransitionType.FADE_OUT, fadeout_sec)
	else:
		SVJukebox.stop(SVJukebox.TransitionType.INSTANT)

## Adjust volume
##
## @deprecated: No alternative yet but I intend to implement an alternative in SVJukebox soon.
func adjust_volume_linear(volume, time_sec):
	## TODO: Add a method for this in upstream so we don't have to break contract
	var player := SVJukebox._current_player
	
	if time_sec == 0:
		player.set_volume_db(linear_to_db(volume))
	else:
		if _current_tween != null:
			_current_tween.kill()
		
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(player, "volume_db", linear_to_db(volume), time_sec)
		tween.play()
		_current_tween = tween

## get currently playing id
##
## @deprecated: No alternative yet but I intend to implement an alternative in SVJukebox soon.
func get_current_music_id():
	return SVJukebox._current_id # TODO: new upstream method to do this

## returns true if anything is playing
##
## @deprecated: No alternative yet but I intend to implement an alternative in SVJukebox soon.
func is_playing():
	return not SVJukebox._current_id.is_empty() # TODO: new upstream method to do this
