# e-ani

**what is it** small game, using Godot. I use Godot with module **futari-addon** (google it(gitlab) ot use this [link](https://gitlab.com/polymorphcool/futari-addon) ), to edit this project you need build Godot with it.

### Using external Assets, [list of all used assets](https://github.com/danilw/e-ani/blob/master/USED_ASSETS_LINKS.md)

**Playable version(binary):** [danilw.itch.io/e-ani](https://danilw.itch.io/e-ani)

**e_ani_multiplayer** this is *Multiplayer* version, by using Godot `rpc()` network. I have test it and it work, critical errors with *wrong node path* on mass node creation/deletion is fixed, but I did not make full-sync, so Godot on Client will display errors with *wrong node path* for first 1-10 frames after object creation on Host. This is very bad and unsafe multiplayer, that I made only for learning Godot multiplayer, *do not use it*. Multiplayer binary versions aviable on danilw.itch.io project page linked above.

**Web version:** this game work in HTML5(wasm) build, and it has [huge problems with ANGLE](https://github.com/godotengine/godot/issues/32189) in webbrowsers, so it only can work in Linux. [Link to web-build](https://danilw.itch.io/e-ani-webgl?password=doit) do not launch it on  Windows.

### Contact: [**Join discord server**](https://discord.gg/JKyqWgt)

### Video:

[![e-ani](https://danilw.github.io/godot-utils-and-other/yt_e-ani.png)](https://youtu.be/0jKyTBFrpjU)
