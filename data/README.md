Creating Custom Maps
--------------------

This game was designed to read in a text file as the map. This makes it very easy to create custom maps.


**Naming**

You will notice a few maps already uploaded. They are named based on the map and the stage like so: `map-level.txt`. The map number can be whatever you like, beecause you will specefy (in the code iteslf) which level you wish to load. The levels must be in numerical order, starting with 1. The game automatically reads in the stages as the user advances, and the user wins when there are no more stages.


**Designing**

*Parameters*

The first line of the text file consists of some parameters. There are three ints seperated by commas, followed by two ints seperated by spaces. The first three numbers are the r,g,b values for the background, the fourth number is the scroll speed of the level, and the fifth number is the background music for that level. Here is a representation: `red,green,blue speed music`
- The r,g,b values must be from 0 to 255, inclusive
- The scroll speed must be from .1 to 1, inclusive. Speed is measured in scrolls/frame. A speed of 1 is the fastest with 1 scroll per 1 frame, and a speed of .1 is the slowest with 1 scroll per 10 frames.
- The music must be from 0 to 4, inclusive. This is because there are only 5 tracks that are added to `String[] songs` in the setup code. Track 0 is just silence.

*Level*

The level must be exactly 16 characters wide. There is no limit to the length of the level.

Each object is represented by a specific character.
- X represents a wall
- D represents a `DumbEnemy`
- E represents an `Enemy`
- S represents a `SmartEnemy`

*Enemies*

Dumb Enemy:
- Flies straight down (speed in pixels/frame is specified when instantiated)
- Does not shoot
- Blows up upon hitting a wall

Enemy:
- Flies toward the location of the user (speed in pixels/frame is specified when instantiated)
- Does not shoot
- Blows up upon hitting a wall

Smart Enemy:
- Flies toward the location of the user (speed in pixels/frame is specified when instantiated)
- Shoots after a particular time interval (interval in ms is specified when instantiated)
- Will not run into walls
