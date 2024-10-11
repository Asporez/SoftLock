# SoftLock

> Are you sentient!? I think I am, this is why I made a CAPTCHA with the Love2D hoping to impress strangers on the internet with my modest programming knowledge.

Softlock is CAPTCHA I built using Lua language with the Löve2D game engine framework for the 2024 LaurieWired Halloween Programming Challenge.

I chose this framework because I felt this challenge was a great opportunity for me to get more familiar with Löve2D and develop a better workflow with GitHub.

LaurieWired YT channel: https://www.youtube.com/@lauriewired

## Usage

*To launch SoftLock run the Launch Softlock shortcut, alternatively run launch.bat, if this does not work drag SoftLock.love on top of SoftLock.exe OR execute command line SoftLock.exe with Softlock.love as argument.*

The test has 2 stages, the first stage asks the user to click on a button that will initiate analysis of trajectory and movement speed.
To ensure there is enough data collected to perform the analyses this phase has another button at the bottom of the screen, slightly offset diagonally.
If the data collected returns as bot-like the program will reset, if there is too little data collected on movement it will reset the program.

The CAPTCHA itself uses a random string generator to print each characters individually and update their positions and color randomly at 60FPS while still being readable for humans.
The font glyph is obfuscated and prints a different character than it registers as input, so if a bot is able to read it the input will be wrong.

**_There are 6 resets possible after which the program will shut down, a user can force the program to 'softlock' if they move the cursor very fast or
if they move to the same points in pefect lines or diagonals, the sensitivity can be adjusted and I tried to include notes to make the program friendly
to improvement and integration of other modules._**

## TOOLBOX

+ Love2D engine: https://github.com/love2d/love
+ Font: https://github.com/shane-tomlinson/connect-fonts-zxx

### Source Content

+ CAPTCHA traslation, rotation, and random color switch at maximum 60FPS.
+ Obfuscated font and glyph with keymapping to handle deobfuscation.
+ program state declaration makes it simple to export calls.
+ Random string generator.
+ Factory pattern table for buttons.
+ Mouse movement speed analysis.
+ Mouse trajectory analysis.
+ Failed checks resets the program and exits afer 6 fails.

### Special Thanks

+ Many of the methods I am using I have learned from listening to https://www.youtube.com/@Stevesteacher crash courses on Love2D.
+ My cats, Polo and Laika.
