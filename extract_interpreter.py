#!/bin/env python3

from d64 import DiskImage

with DiskImage('disks/BOOT.D64') as image:
    with image.path(b'AA').open() as in_f:
        with open('aa.prg', 'wb') as out_f:
            out_f.write(in_f.read())
