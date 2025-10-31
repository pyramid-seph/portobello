# v5.1.1 - The one that still paints signs.

* Fixed a build config that showed weird symbols on some labels.


# v5.1.0 - The one that does not code.

* Changed the RPG battle start animation.
* Enabled fallback text server.
* Removed dev addons from exported projects.
* Migrated to Godot 4.5.1.


# v5.0.1 - The one that paints signs.

* Fixed a build config that showed weird symbols on some labels.


# v5.0.0 - The one that finally bites the apple...sorta.

* Experimental support for Safari running on MacOS.
* Made this game a PWA.
* Fixed an error that made the cheatcode to unlock all levels take effect only 
after restarting the game.
* Migrated to Godot 4.5.


# v4.2.0 - The one that remembers fondly.

* Added an in memoriam for Bucho the cat.
* Improved visibility of the game's logo on the title screen.
* Improved visibility of the game's version on the title screen.
* Changed the flow of RPG battles so they require less inputs.
* Added some sound effects to RPG battles.
* Changed the advance battle narration sound again again.
* Fixed an error that made poison damage messages not last long enough to be read.
* Fixed incorrect touch controller mode on the shader precompilation screen.
* Fixed typos on Day EX ability descriptions.
 

# v4.1.0 - The one that no longer stutters.

* From now on, a long press is required to skip cutscenes.
* Added SPACE and A BUTTON to the list of inputs that skip cutscenes.
* Fixed stutters that sometimes happen when the title screen appears.
* Fixed english localization errors.
* Changed the sound for advancing the battle narration on Day EX.
* Reduced the volume of the game start sound.
* Added missing credit for Kenney for their Kenney Interface Sounds files.
* Minor code cleanup.


# v4.0.0 - The one with charisma.

* From now on, you can skip each intro logo by pressing A/B (Xbox controller), 
ESC/SPACE (keyboard), or by touching the skip button (mobile).
* Added a screen to ensure web audio is activated.
* Added a "Press to start" screen.
* Added an attract mode cutscene. It is played after the intro logos and after 
60 seconds of inactivity on the "press to start" screen. This cutscene sets up 
the game's story. You can skip it by pressing B (Xbox controller), 
ESCAPE (keyboard), or by touching the skip button (mobile).
* Updated credits.
* Polished the ending (just a little!).
* Implemented Github Actions to automate the release of production builds.
* This is the first version to also be hosted on Github Pages.
* Reduced the build size by stripping some unused Godot modules and by using 
custom export templates.


# v3.0.0 - The one that beeps and boops.

* Sound effects!
* Show the total number of levels for each story mode minigame.
* Touched up some images, the pause menu, the title screen and some cutscenes.
* Migrated to Godot 4.4.1.


# v2.2.0 - The one that cheats.

* Added a cheatcode (based on certain one that starts with "K") that unlocks 
all games in story and arcade modes. Input it while the logos are rolling. 
**Does not work with touch controllers**.
* Hides the cursor after not moving it for 1 second. Move your mouse to show it again.
* Improvement: ghosts no longer move back. This reduces the likelihood of them 
ping-ponging.
* Fix: some pixel flashing.


# v2.1.0 - The one that doesn't drink coffee.

* Enabled physics interpolation.
* Fixed some small bugs.


# v2.0.1 - The one that remembers the rules.

* Fixed an error that let the player get loot and experience when fleeing from battle.


# v2.0.0 - The one that role plays.

* Added "Day EX", a mini RPG you can access after beating the game.
* Fix: touch controller keeps sending inputs when its mode changes.
* Migrated to Godot 4.3.


# v1.2.1 - The one that hunts ghosts.

* Fix: the scene change indicator animates when invisible.
* Fix: the second boss of day 3 keeps exploding when the results screen is visible.  


# v1.2.0 - The one that needs a hug.

* Touchscreen support (mobile devices only). The touchscreen controller is only 
shown if no physical gamepad is connected to the mobile device.
* Vibrate mobile devices instead of the physical gamepad if 
the touch screen controller is active.
* Fixed a minor english localization error.


# v1.1.0 - The one that speaks english.

* English localization. The first time you play this version, the language of the
game will be matched to the one of your system. If your system language is 
not supported, english will be used.
* From now on, you can see the current level of day 1 (story mode only) and day 2.
* From now on, you can use AWSD to move on menus.


# v1.0.0 - The one that started it all.

* Initial release. This version closely resembles the original game, 
but it adds some minor changes to gameplay, UI and art. 
It also restores the original bad guy which was removed because the minigame 
that introduces him didn't make it to the released product.
