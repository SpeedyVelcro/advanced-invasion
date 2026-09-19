Update 1.1 brings a major overhaul targeted at several major pain points in the game. The headline items are a more forgiving experience on the lower difficulty, an overhauled final boss battle, improved cutscenes and dialogue in the middle of the game, and a major interface overhaul.

You will also see a slew of social icons on the main menu. If you enjoyed Advanced Invasion, please do consider following me to keep up with my future work.

### Mechanics
- Difficulty settings have been renamed. Casual is now Standard, and Normal is now Hardcore.
- Boss battles now have slightly easier mechanics on standard difficulty. The difficulty descriptions have been updated to reflect this.
- When playing on standard, respawn mechanics have been improved.
  - If you have lives left, you will teleport to a safe location after falling into pits (whether bottomless or heat blocks) instead of restarting the level.
  - On certain moving platform levels, where waiting for the platform to return would take way too long, the platform snaps back to an accessible location if you respawn.
  - This means that the extra lives granted to you by Standard mode should now be helpful in all situations in the game.
- Major overhaul to the final battle
  - The final battle now includes viruses with shields on top.
  - In the final battle, your ally now has to contend with horizontally-shielded viruses as well. They are also able to react intelligently to a few more situations. This should make the battle feel a little more fair, and also give you an example of what to do to win the battle.
  - In the final battle, your ally now also has lives if you are playing on standard.

### Story
- Added extra expository dialogue before the first cutscene fades in.
- Overhauled the second meeting with your teal ally into a full level. Dialogue has been completely overhauled in this level and most of it is completely new.
- Overhauled post-boss cutscene after the square virus boss with new dialogue and different animation.

### UI
- The UI now scales when playing on high resolutions (e.g. 4K). There is a slider in the options menu to customise this behaviour.
- Improved UI styling, covering many previously unstyled elements.
- Added controller support to menus.
- Overhauled main menu with a nicer-looking and more usable layout.
- Added social links to the main menu.
- Overhauled the jukebox. It now has freshly-written per-track liner notes, and supports complex playback features like shuffle or looping individual tracks.
- Overhauled options menu.
- Added custom keybinds to options menu.
- Made minor changes to achievement menu and popups (these are a consequence of under-the-hood changes)
- The achievement menu is now accessible from the pause menu.
- Overhauled about menu. Third-party license information is now clearer, more thorough, and separated from the credits.

### Bugfixes
- Fixed jitter when the player character moves.
- Fixed a previously broken non-functional feature that would have allowed you to zoom the camera manually. You can now use the scroll wheel to zoom in and out.
- Fixed bullet firing when using spacebar to close dialogue

### Technical
- Migrated engine version to Godot 4.7.2.
- Simplified display settings on the web platform (resolution now automatically adjusts to the size of the canvas on web).
- Overhauled how achievements work under-the-hood.
- Several save file formats have been changed. Existing files will automatically be upgraded when you start the game.
- Calculation of valid zoom levels for the camera have been changed. You may see slightly different zoom levels than before on certain resolutions.

