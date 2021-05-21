extends Control

signal back

export(NodePath) var entry_parent_path # Node to which entries are added as children
onready var entry_parent = get_node(entry_parent_path)
var entries = []
var separators = []

const ACHIEVEMENT_ORDER = [
	"defeat_giant",
	"defeat_square",
	"defeat_wizard",
	"complete_casual",
	"complete_normal"
]
const ACHIEVEMENT_ENTRY = preload("res://GUI/AchievementsMenu/AchievementEntry.tscn")
const SEPARATOR = preload("res://GUI/AchievementsMenu/AchievementSeparator.tscn")
const SECRET_ICON = preload("res://Art/Achievement/Secret.png")
const SECRET_TITLE = "Secret Achevement"
const SECRET_DESCRIPTION = "Unlock this achievement to discover what it is."

func show():
	populate() # Do this every time menu is shown just in-case achievements were unlocked on main menu
	# Also just in case integration settings were changed, so sync buttons get updated.
	visible = true

func hide():
	visible = false

func populate():
	depopulate()
	var achievements = AchievementManager.get_achievement_list()
	# First populate achievements in specified order
	for id in ACHIEVEMENT_ORDER:
		var index = achievements.find(id)
		if index != -1:
			insert_achievement(id)
			achievements.remove(index)
	# Then populate any achievements unaccounted for
	for id in achievements:
		insert_achievement(id)

func insert_achievement(id : String):
	# Create separator
	if not entries.empty():
		var separator = SEPARATOR.instance()
		separators.append(separator)
		entry_parent.add_child(separator)
	# Create entry
	var entry = ACHIEVEMENT_ENTRY.instance()
	entries.append(entry)
	entry_parent.add_child(entry)
	# Set entry details
	# TODO: call a set_achievement_id(id) function and move all this code
	# into the AchievementEntry, it doesn't need to be here.
	var unlocked = AchievementManager.is_achievement_unlocked(id)
	var secret = AchievementManager.is_achievement_secret(id)
	if secret and not unlocked:
		entry.set_icon(SECRET_ICON)
		entry.set_title(SECRET_TITLE)
		entry.set_description(SECRET_DESCRIPTION)
		entry.set_target_enabled(false)
	else:
		entry.set_icon(AchievementManager.get_achievement_icon(id))
		entry.set_title(AchievementManager.get_achievement_title(id))
		entry.set_description(AchievementManager.get_achievement_description(id))
		if AchievementManager.is_achievement_target_enabled(id):
			entry.set_target_enabled(true)
			var progress = AchievementManager.get_achievement_progress(id)
			var target = AchievementManager.get_achievement_target(id)
			var dp = AchievementManager.get_achievement_target_dp(id)
			entry.set_progress(progress, target, dp)
		else:
			entry.set_target_enabled(false)
	entry.set_locked(not unlocked)
	var integration_check = NewgroundsIntegration.is_integration_enabled() or GameJoltIntegration.is_integration_enabled()
	if unlocked and integration_check:
		entry.set_sync_enabled(true)
		entry.connect("synced", self, "_on_AchievementEntry_synced", [id])
	else:
		entry.set_sync_enabled(false)

func depopulate():
	for entry in entries:
		entry.queue_free()
	entries = []
	for separator in separators:
		separator.queue_free()
	separators = []

func _on_BackButton_pressed():
	emit_signal("back")

func _on_AchievementEntry_synced(achievement_id : String):
	AchievementManager.sync_achievement(achievement_id)
