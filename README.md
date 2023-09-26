# zak2crt

Convert C64 Zak McKracken disks to a .crt.

## Requirements

[TMPx](http://turbo.style64.org/)TMPx for compiling the .asm sources. Put a
link to a working binary in ./tools/tmpx.

[Python module d64](https://pypi.org/project/d64/) to extract the aa.prg from
the bootdisk. You can also extract it manually and just put it the root folder
of this project.

The game itself, the original uncracked version. Other versions are not tested.
Put the 3 disks in disks/ as follows:

- BOOT.D64
- SIDE1.D64
- SIDE2.D64

## Building

Run ./make. This should create a cart.crt which you can use in Vice
or CCS64 (and maybe others, not tested)


## Current issues

### Loading/Saving of games

We need to leave the original disk handling code in place, so the save/load
game feature can use it's own disk. Currently we overwrite the disk handling
code which is why saving/loading of games does not work at the moment.


### Graphical Gliches

Game shows glitches while loading. Caused by the interupt being disabled
causing timing issues with the splitscreen. We currently work around this by
loading sectors while the vic is drawing the borders. On PAL this seems to
work, on NTSC it still glitches. There's not much border on NTSC systems.
