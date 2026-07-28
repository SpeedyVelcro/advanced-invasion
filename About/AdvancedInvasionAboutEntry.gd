class_name AdvancedInvasionAboutEntry
extends SVAboutEntry


# Override
func get_title() -> String:
	return ProjectSettings.get_setting_with_override("application/config/name")


# Override
func get_description() -> String:
	return VersionNumber.value + "" \
			+ "\nCopyright © 2021-2026 SpeedyVelcro" \
			+ "\nAll Rights Reserved" \
			+ "\n" \
			+ "\n[url]https://speedyvelcro.com/games/advanced-invasion[/url]" \
			+ "\nSource Code: [url]https://github.com/SpeedyVelcro/advanced-invasion[/url]" \
			+ "\n" \
			+ "\nUse the buttons on the left to see full credits, and licenses for all applicable assets and components."
