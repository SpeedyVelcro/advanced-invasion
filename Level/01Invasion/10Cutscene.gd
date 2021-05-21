extends Level

func _on_cutscene_skip():
	DialogueManager.cancel_dialogue()
	$CutsceneChaperone/AnimationPlayer.stop()
	$CutsceneChaperone.end()
