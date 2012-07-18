# Mirror: the Game that Plays You

My 2010 BFA thesis project from the Cleveland Institute of Art.

## What is Mirror?

##### An excerpt from my thesis paper:

> Mirror is a simple 2D physics game in which the player controls an avatar, trying to climb, swing, and roll to the goal. The interactions aim to find new and unique meaningful inputs that expand our perceptions to include the input device and game into an holistic experience. This unique input data can be translated into smooth, pleasurable control over a virtual avatar that sympathizes with the player as the player sympathizes with it. This experience will hopefully evolve into something greater than the sum of its parts, enticing its users to think about, create, and perhaps expect games that exhibit a greater depth of seamless interaction with the devices they manipulate.

My thesis paper can be found at [my website](http://www.coryhughart.com/portfolio/games/mirror/thesis.pdf). I made it into a book for the presentation, which is available at [blurb.com](http://blurb.com/bookstore/detail/1305563), free to read and download. You can even purchase a hard-bound copy if you feel inclined.

All that aside, Mirror is a game that involves controling an avatar's hands with 2 computer mice. Move a mouse to move the corresponding hand, then press the mouse button (with your index finger) in order to grab hold of a block. Other features include webcam face recognition and placement on the avatar, an auto-reset during idle time (it was developed to run as a kiosk for a full week), and a sense of unrestrained glee at scaling walls in leaps and bounds.

Check out http://coryhughart.com/#mirror for screenshots, a teaser vid, and photos of the installation.

## How do I play Mirror?

##### In three words: I'm not sure.

I set this code down after I graduated in May 2010 to move on to new projects (and a new job). It's frankly a mess, as it was one of my first attempts to code a playable game.

If you are familiar with [Processing](http://www.processing.org), you may be able to get this up and running if you have:
 * The [Processing IDE](http://processing.org/download/)
 * Various communty-provided libraries (included with source)
 * A webcam or iSight
 * An [Arduino](http://arduino.cc/en/) with [Firmata](http://www.arduino.cc/playground/interfacing/processing) installed (I was using an Arduino Diecimila and an Arduino Mini (v04?) at the time)
 * 2 USB computer mice custom-rigged with vibrating motors
 * A Mac*

_*Though Java, and by extension Processing, is cross-platform, the library I used to handle input from 2 USB mice did not work on Windows at the time._

Mirror _will_ run without the custom mice (but 2 USB mice _are_ required), _will not_ run without an Arduino (with Firmata installed) plugged in, and will _probably break_ without a webcam. Even if you have all of the above it may _still_ not work, considering the Processing IDE has been updated since 2010 and Mac OS X Lion+ compatibility nightmares. This repository is mostly for archival and sharing purposes and is not under active development, so it is possible that these problems may not get fixed. When I eventually get to building a real game out of this concept, I won't be using this source code anyways. But I've open-source'd it because everything I used to make this game is open source, and it's only fair. I hope that at least some of this code is helpful or inspirational to others.

If you somehow do get this working, please let me know!