# ripple

A little 2D lua game written inside of an 18-hour period. Made with
[LÖVE][love].

The more times you jump, the more points you get. The more times you jump, the
more ripples you make. And you can't touch the ripples.

# Installing

You can find the latest compiled releases for various platforms under the
[releases][releases] tab

## Mac/Windows

From the latest release under the [releases][releases] tab, download and extract
the zip file for your platform

### Windows

Simply run `ripple.exe`

### Mac

When you unzip you'll get a `ripple.app` folder. I'm not really sure what you're
supposed to do with it, since I've never used a Mac. If you know, please send a
PR to update these docs! :)

## Linux

From the latest release under the [releases][releases] tab, download the
`ripple.love` file. You'll need to install the [LÖVE][love] binary. Once done,
simply:

    love ripple.love

To run the game

# Development

## Build

First download and install [love][love], then simply:

    make clean run

[love]: https://love2d.org/
[releases]: https://github.com/mediocregopher/ripple/releases

