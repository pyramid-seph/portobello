# v4.0.0 - The one with charisma.

* Now you can skip each intro logo by pressing A/B (Xbox controller), 
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


# v2.1.0 - The one with less jitter.

* Enabled physics interpolation.
* Fixed some small bugs.


# v2.0.1 - The one that remembers the rules.

* Fix an error that let the player get loot and experience when fleeing from battle.


# v2.0.0 - The one that role plays.

* Added "Day EX", a mini RPG you can access after beating the game.
* Fix an error that makes the touch controller keeps sending inputs when 
the touch controller mode changes.
* Migrated to Godot 4.3.


# v1.2.1 - The one that fixes invisible stuff running.

* Fix: the scene change indicator animates when invisible.
* Fix: the second boss of day 3 keeps exploding when the results screen is visible.  


# v1.2.0 - The one that supports touchscreens.

* Touchscreen support (mobile devices only). The touchscreen controller is only 
shown if no physical gamepad is connected to the mobile device.
* Vibrate mobile devices instead of the physical gamepad if 
the touch screen controller is active.
* Fix a minor english localization errors.


# v1.1.0 - The one that speaks english.

* English localization. The first time you play this version, the language of the
game will be matched to the one of your system. If your system language is 
not supported, english will be used.
* Now you can see the current level of day 1 (story mode only) and day 2.
* Now you can use AWSD to move on menus.


# v1.0.0 - The one that started it all.

* Initial release. This version closely resembles the original game, 
but it adds some minor changes to gameplay, UI and art. 
It also restores the original bad guy which was removed because the minigame 
that introduces him didn't make it to the released product.
