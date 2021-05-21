extends Node

# Keeps an eye on game state and calls methods from AchievementManager

func _ready():
	# Then when a node is added depending on the node it has signals connected
	# to the watchdog e.g. signal for killing a virus
	# I might not actually use this in the end though
	get_tree().connect("node_added", self, "_on_tree_node_added")
	GameStatus.connect("story_complete", self, "_on_GameStatus_story_complete")
	GameStatus.connect("story_normal_complete", self, "_on_GameStatus_story_normal_complete")

func _on_tree_node_added(node : Node):
	# BIG WARNING: node_added signal is not emitted if you start the game from this scene.
	# Not a problem normally as we start from Main.tscn, but if you use "Play Scene"
	# in the editor, this may result in achievements not being earned.
	
	#if node.is_in_group("creep"):
	#	node.connect("death", self, "_on_creep_death")
	# BOSS
	if node.is_in_group("boss"):
		match node.name:
			"Giant":
				node.connect("death", self, "_on_boss_giant_death")
			"SquareVirus":
				node.connect("death", self, "_on_boss_square_death")
			"WizardFight":
				node.connect("death", self, "_on_boss_wizard_death")

func _on_boss_giant_death():
	AchievementManager.unlock("defeat_giant")

func _on_boss_square_death():
	AchievementManager.unlock("defeat_square")

func _on_boss_wizard_death():
	AchievementManager.unlock("defeat_wizard")

func _on_GameStatus_story_complete():
	AchievementManager.unlock("complete_casual")

func _on_GameStatus_story_normal_complete():
	AchievementManager.unlock("complete_normal")

#func _on_creep_death():
#	AchievementManager.add_progress("kill_10", 1)
