# sdioretsa
A space rocks game from the spaceship's perspective

With much inspiration from a well known arcade game by [Atari](https://atari.com/)™️

For the rest of our games check out our [Itch.io](https://abemassry.itch.io/) page

This game has also been posted to the Lexaloffle PICO-8 BBS: [Sdioretsa](https://www.lexaloffle.com/bbs/?tid=54730)

## Sdioretsa

![title screen](https://wsnd.io/rsJEYl2O/sdioretsa-title.png)

## Attract Mode
The game starts off like many arcade games in attract mode.

![attract mode](https://wsnd.io/epEEoUvP/sdioretsa_7.gif)

The ❎ button starts the game

## Gameplay
The gameplay has the entire playing field rotating around the ship, like you're playing the game from the ship's perspective.

![gameplay](https://wsnd.io/BMQLJYfv/sdioretsa_10.gif)

The 🅾️ button fires bullets and right and left rotate. Up provides the thrust to the ship.

There is room for one high score save, the top high score.


## Development
The original idea was to make an easier to control space shooter, but in implementing the physics-esque engine accurately many things come together to make it almost as difficult as original space shooters. This probably primarily comes from the difficulties in navigating space with only a thrust in one direction and not much drag on the spaceship.

The next part of development was the rotation instead of rotating sprites which was too slow, the people on the pico-8 discord suggested rotating vectors. Since the rocks would be very difficult to draw like a vector, it was decided to use a series of points, being that the PICO8 is a raster/pixel based engine, unlike the original games of this style which were vector based.

The player's angle of rotation is a global so everything is passed through a rotation function each frame and when the global angle changes the rotation of the entire playing field changes. The only things that don't rotate are the player's ship and the hud elements. Everything else, rocks, ufos, bullets (both ship and ufo bullets) rotates when the ship rotates. In addition the rotatable elements also respect the thrust of the ship as well with the thrust being a global as well.

The bullets were also challenging to time, the goal was 4 at a time and then a break and that was mostly achieved but there was difficulty due to the playing field size.

The particle effects were taken from [Rain Drop](https://github.com/abemassry/rain-drop) and modified.

The label image was designed in [Aseprite](https://www.aseprite.org/)

The audio is all `sfx` and the music is timed based on this concept of how much "weight" is contained in the rocks. All the other music and sound effects are called with `sfx` and repeated.

## Have fun
I hope you have fun playing.

## Special Thanks
Thank you to everyone who tuned in on [Twitch](https://www.twitch.tv/abemassry) during the development, and thank you to all of our followers.
And thank you to everyone in the discord channel who provided feedback and support during the development process
And a very special thanks to my friend [Kenji](https://twitter.com/kenjihasegawa) who was there every step of the way.
