# Dialogue.gd
# Dear god this script is a mess. I'm so sorry.

extends CanvasLayer

onready var viewport = get_tree().get_root()
onready var gradient_polygon = get_node("Polygon2D")
onready var name_label = $Control/VBoxContainer/HBoxContainer/NameLabel
onready var dialogue_label = $Control/VBoxContainer/HBoxContainer/DialogueLabel
onready var voice_audio_player = $VoiceAudioStreamPlayer
export var gradient_height_proportion = 0.3
var gradient_visible_y = 0.0 # Overwritten automatically
var gradient_hidden_y = 0.0 # Overwritten automatically
export var gradient_visibility = 0.0 setget set_gradient_visibility, get_gradient_visibility # Number between 0 and 1
var currently_displayed = false
enum {STATE_IDLE, # Off screen or going through display/hide animation
		STATE_TYPEWRITER, # Typing out text
		STATE_PAUSE} # Typing finished, waiting either for input or predetermined length of time.
var state = STATE_IDLE
var cumulative_delta = 0
var typewriter_speed = 30
var dialogue_queue = []
var color_resource = preload("res://AutoLoad/DialogueManager/DialogueColors.tres")
var last_character_was_stop = false
var stop_speed_multiplier = 0.3
var stop_characters = [".", "!", "?", ";", ",", ":", "-"]
var end_broadcast = []
const VOICE_SYTNH_PITCH = 1.0
const VOICE_SYNTH_PITCH_VARY = 0.2
onready var rng = RandomNumberGenerator.new()

signal finished
signal hidden
signal broadcast(message)
signal end_broadcast(message)

func _ready():
	viewport.connect("size_changed", self, "_on_viewport_size_changed")
	_on_viewport_size_changed() # Adapt size once
	gradient_polygon.set_visible(false)
	name_label.set_visible(false)
	dialogue_label.set_visible(false)
	_on_state_enter()

func _process(delta):
	match state:
		STATE_IDLE:
			pass
		STATE_TYPEWRITER:
			# RichTextLabel functions have a delayed update. So we first make sure
			# that get_total_character_count() is a not-stupid value.
			# (On testing, immediately after advanced_dialogue() this is 0, which
			# makes it a good way of checking.)
				# TODO: a more bullet-proof way of doing this would be to only call
				# get_total_character_count() in a call_deferred(). Should be considered
				# for a refactor.
			if dialogue_label.get_total_character_count() != 0:
				if Input.is_action_just_pressed("ui_accept") and (not dialogue_queue[0].ignore_input):
					# skip
					dialogue_label.set_visible_characters(dialogue_label.get_total_character_count())
					# End of typewriter process will detect this and change state to pause
				else:
					# continue adding characters
					# Skip whitespace
					# TODO: I'm about 90% sure this is redundant because we skip whitespace again below.
					while dialogue_label.get_visible_characters() < dialogue_label.get_total_character_count():
						var next_char_index = dialogue_label.get_visible_characters()
						var next_char = char(dialogue_label.get_text().ord_at(next_char_index))
						if next_char == " " or next_char == "\t":
							dialogue_label.set_visible_characters(dialogue_label.get_visible_characters() + 1)
						else:
							break
					
					cumulative_delta += delta
					var prev_chars = dialogue_label.get_visible_characters()
					while dialogue_label.get_visible_characters() < dialogue_label.get_total_character_count():
						var mult = get_speed_multiplier()
						# Skip whitespace
						var next_char_index = dialogue_label.get_visible_characters()
						var next_char = char(dialogue_label.get_text().ord_at(next_char_index))
						if next_char == " " or next_char == "\t":
							dialogue_label.set_visible_characters(dialogue_label.get_visible_characters() + 1)
						# Type through regular characters
						elif cumulative_delta * typewriter_speed * mult > 1.0:
							cumulative_delta -= 1.0 / (typewriter_speed * mult)
							# Must use set_visible_characters() as this is overridden in DialogueLabel.gd
							dialogue_label.set_visible_characters(dialogue_label.get_visible_characters() + 1)
							# Update fullstop status
							last_character_was_stop = stop_characters.has(next_char)
						else:
							break
					if dialogue_label.get_visible_characters() > prev_chars:
						play_voice_synth()
				if (dialogue_label.get_visible_characters() >= dialogue_label.get_total_character_count()):
					#print("Advanced. Visible characters was " +
					#		String(dialogue_label.get_visible_characters()) +
					#		", total characters was " +
					#		String(dialogue_label.get_total_character_count()))
					change_state(STATE_PAUSE)
		STATE_PAUSE:
			if not dialogue_queue[0].ignore_input:
				if Input.is_action_just_pressed("ui_accept"):
					advance_dialogue()

func get_speed_multiplier():
	var mult = dialogue_label.get_speed_multiplier()
	if last_character_was_stop:
		mult *= stop_speed_multiplier
	return mult

func _on_state_enter():
	match state:
		STATE_IDLE:
			if currently_displayed:
				$AnimationPlayer.play("hide")
		STATE_TYPEWRITER:
			pass
		STATE_PAUSE:
			if dialogue_queue[0].auto_advance:
				if dialogue_queue[0].pause_sec > 0:
					$PauseTimer.start(dialogue_queue[0].pause_sec)
				else:
					# We emit the signal manually because starting with 0 secs doesn't seem to do anything
					$PauseTimer.emit_signal("timeout")

func _on_state_exit():
	match state:
		STATE_IDLE:
			pass
		STATE_TYPEWRITER:
			cumulative_delta = 0
		STATE_PAUSE:
			$PauseTimer.stop()
			# dialogue_label.set_visible_characters(0) # This is now done in advance_dialogue()

func change_state(p_state):
	_on_state_exit()
	state = p_state
	_on_state_enter()

func _on_PauseTimer_timeout():
	advance_dialogue()

func queue_dialogue(dg_list = [], p_end_broadcast = "", display_immediately = true, override = false):
	# Override clears the dialogue queue and allows interrupting other dialogue
	# rather than following on
	if override:
		dialogue_queue = []
	if p_end_broadcast != "":
		end_broadcast.append(p_end_broadcast)
	dialogue_queue += dg_list
	if display_immediately and ((state == STATE_IDLE) or override):
		display()

func advance_dialogue() -> bool:
	# Returns true if there was dialogue following.
	last_character_was_stop = false
	if dialogue_queue.size() >= 1:
		dialogue_queue.pop_front()
		if dialogue_queue.size() >= 1:
			update_dialogue()
			dialogue_label.set_visible_characters(0)
			change_state(STATE_TYPEWRITER)
			if dialogue_queue[0].broadcast_enabled:
				emit_signal("broadcast", dialogue_queue[0].broadcast_message)
			return true
		else:
			change_state(STATE_IDLE)
			$AnimationPlayer.play("hide")
			emit_signal("finished")
			for message in end_broadcast:
				emit_signal("end_broadcast", message)
			end_broadcast = []
			return false
	else:
		push_error("Tried to advance dialogue when no dialogue was currently being displayed")
		return false

func display():
	if dialogue_queue.size() >= 1:
		currently_displayed = true
		update_dialogue()
		dialogue_label.set_visible_characters(0)
		$AnimationPlayer.play("show")
	else:
		push_error("Attempted to display dialogue with no dialogue in queue")

func update_dialogue():
	name_label.set_text(dialogue_queue[0].character_name + ":")
	dialogue_label.set("custom_colors/default_color", color_resource.get_color(dialogue_queue[0].character_color_id))
	var txt = "[center]" + tr(dialogue_queue[0].bbcode) + "[/center]"
	dialogue_label.set_bbcode(txt)

func hide():
	# Not sure that this function is even necessary but leaving it in for now just in case
	$AnimationPlayer.play("hide")

func cancel_dialogue(instant = false, clear_queue = true):
	dialogue_queue = []
	change_state(STATE_IDLE)
	if instant and $AnimationPlayer.is_playing():
		$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"show":
			if dialogue_queue.size() >= 1:
				change_state(STATE_TYPEWRITER)
		"hide":
			emit_signal("hidden")

func _on_viewport_size_changed():
	var size = viewport.size
	# Adjust polygon
	var top_left = Vector2(0, 0)
	var top_right = Vector2(size.x, 0)
	var bottom_left = Vector2(0, size.y * gradient_height_proportion)
	var bottom_right = Vector2(size.x, size.y * gradient_height_proportion)
	var vertices = gradient_polygon.get_polygon()
	vertices.set(0, top_left)
	vertices.set(1, top_right)
	vertices.set(2, bottom_right)
	vertices.set(3, bottom_left)
	gradient_polygon.set_polygon(vertices)
	gradient_hidden_y = size.y
	gradient_visible_y = ceil(size.y * (1.0 - gradient_height_proportion))
	# Update position of polygon as values it depends on have changed
	set_gradient_visibility(get_gradient_visibility())

func play_voice_synth():
	var pitch = VOICE_SYTNH_PITCH - VOICE_SYNTH_PITCH_VARY
	pitch += rng.randf() * VOICE_SYNTH_PITCH_VARY * 2
	voice_audio_player.set_pitch_scale(pitch)
	voice_audio_player.play()

# Setters and getters
func set_gradient_visibility(value):
	gradient_visibility = value
	if gradient_polygon == null:
		return
	var pos = gradient_polygon.get_position()
	pos.y = gradient_hidden_y * (1 - gradient_visibility) + gradient_visible_y * gradient_visibility
	gradient_polygon.set_position(pos)

func get_gradient_visibility():
	return gradient_visibility
