# Advanced Invasion

Advanced Invasion is a fangame of Blublub's Virus Invasion series. You can play
it on [Newgrounds](https://www.newgrounds.com/portal/view/project/1626557),
[itch](https://speedyvelcro.itch.io/advanced-invasion) or
[Game Jolt](https://speedyvelcro.itch.io/advanced-invasion).

![Advanced Invasion screenshot](readme-screenshot.png)
## Compiling
**NOTE** This is for building the game from source code. If you just want to
play it, I recommend downloading/playing it on Newgrounds, Game Jolt or itch.

* Download Godot 4.7
* In the project manager, import the project.godot file and open the project.
* Project > Export
* Select the preset for your platform and click "Export Project".
* Find the exported project in the compiled folder. There are subdirectories for all the export presets.

You can alternatively create your own export preset.

## Release Process
The pipeline will automatically create releases and tags when you push
a main version tag to the repository. A main version tag is a tag in
the form `vX.X.X`, with no extra information appended.

Creating a tag or a release using a tag `vX.X.X` will automatically
create tags and releases for Newgrounds and Game Jolt via the
pipelines. These releases will be tagged `vX.X.X-ng` and `vX.X.X-gj`
respectively.

While creating the tag directly and creating the release have the same
effects, creating the tag directly makes the pipelines look a little
nicer and less confusing. GitHub doesn't have a way to create tags
directly, so run the following commands:
```bash
git tag vX.X.X
git push origin tag v0.0.0
```

## License
Please see `LICENSE.md`. The following is just a summary.

**Note that this repository has some non-free content.** This is because it is a
fan-game of Blublub's Virus Invasion. Virus Invasion is abandonware with an
established history of allowing fangames.

Regardless, I've licensed as much fully original content as I can under free
licenses. And as for the rest, in general I am personally fine with people
redistributing or modifying it for non-commercial purposes, and I know Blublub
was generally fine with people making fangames before he disappeared. So use your
own discretion.
