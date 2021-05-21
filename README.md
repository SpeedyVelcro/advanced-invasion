# Advanced Invasion

Advanced Invasion is a fangame of Blublub's Virus Invasion series. You can play
it on [Newgrounds](https://www.newgrounds.com/portal/view/project/1626557),
[itch](https://swiftvector.itch.io/advanced-invasion) or
[Game Jolt](https://swiftvector.itch.io/advanced-invasion).

## Compiling
**NOTE** This is for building the game from source code. If you just want to
play it, I recommend downloading/playing it on Newgrounds, Game Jolt or itch.

* Download Godot 3.2.3
* In the project manager, import the project.godot file and open the project.
* Project > Export
* Select the preset for your platform and click "Export Project".
* Find the exported project in the compiled folder. There are subdirectories for all the export presets.

You can alternatively create your own export preset.

## License
Please see `LICENSE.md`. The following is just a summary.

**Note that this repository has some non-free content.** This is because it is a
fan-game of Blublub's Virus Invasion. Virus Invasion is abandonware with an
established history of allowing fangames.

Regardless, I've licensed as much fully original content as I can under free
licenses. And as for the rest, in general I am personally fine with people
redistributing or modifying it for non-commercial purposes.

## API keys
This information is really only provided for myself in-case I forget
it. It's probably only useful for you if you use Advanced Invasion source code
as a base for your game to upload on Newgrounds/Game Jolt.

If you are not using the Newgrounds or Game Jolt APIs, you can diregard this
info.

It is recommended you run the following commands in order to avoid accidentally
pushing private keys and app IDs to a public repository.

```
git update-index --assume-unchanged AutoLoad/GameJoltIntegration/GameJoltSecret.gd
git update-index --assume-unchanged AutoLoad/NewgroundsIntegration/NewgroundsSecret.gd
```

To undo this run the following

```
git update-index --no-assume-unchanged AutoLoad/GameJoltIntegration/GameJoltSecret.gd
git update-index --no-assume-unchanged AutoLoad/NewgroundsIntegration/NewgroundsSecret.gd
```
