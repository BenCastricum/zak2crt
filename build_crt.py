#!/bin/env python3

import argparse

parser = argparse.ArgumentParser(description='C64 .crt builder for Zak Mckracken ')
parser.add_argument('interpreter', metavar='interpreter', type=str, help='The file to use as interpreter')
parser.add_argument('-o', '--outfile', default='cart.crt', type=str, help='The file to be created')

# https://codebase64.org/doku.php?id=base:crt_file_format

name = 'ZAK MCKRACKEN'
if len(name) > 32:
    raise ValueError('Title too long (%d > 32)' % len(name))

header = bytearray(0x40)
header[ 0:16] = bytes("C64 CARTRIDGE   ", 'ascii')  # Signature
header[16:20] = (0x00, 0x00, 0x00, 0x40)            # File header length
header[20:22] = (0x01, 0x00)                        # Cartridge version
header[22:24] = (0x00, 0x13)                        # Cartridge hardware type
header[24]    = 0x00                                # EXROM line status
header[25]    = 0x01                                # GAME line status

header[32:32+len(name)]    = bytes(name, 'ascii')

chip_header = bytearray(0x10)
chip_header[ 0: 4] = bytes("CHIP", 'ascii')         # Signature
chip_header[ 4: 8] = (0x00, 0x00, 0x20, 0x10)       # Total packet length
chip_header[ 8:10] = (0x00, 0x00)                   # Chip type
chip_header[10:12] = (0x00, 0x00)                   # Bank number
chip_header[12:14] = (0x80, 0x00)                   # Starting load address
chip_header[14:16] = (0x20, 0x00)                   # ROM image size

args = parser.parse_args()
filename = args.interpreter

roms = []
raw_rom = bytearray()

with open("loader.prg", 'rb') as file:
    rom = file.read()
    roms.append({ 'description': "loader.prg", 'data' : rom[2:] })

with open(filename, 'rb') as file:
    rom = file.read()
    roms.append({ 'description': filename, 'data' : rom[2:] })

with open("disks/SIDE1.D64", 'rb') as file:
    rom = file.read()
    roms.append({ 'description': 'SIDE1.D64', 'data' : rom })

    rest = 8192 - (len(rom) % 8192)
    roms.append({ 'description': 'padding', 'data' : bytearray(rest) })

with open("disks/SIDE2.D64", 'rb') as file:
    rom = file.read()
    roms.append({ 'description': 'SIDE2.D64', 'data' : rom })

with open(args.outfile, 'wb') as cart:
    cart.write(header)

    while raw_rom or roms:
        while len(raw_rom) < 8192 and roms:
            rom = roms.pop(0)
            print("chip %2d offset $%04X %14s (size $%05X)" % (chip_header[11], len(raw_rom), rom['description'], len(rom['data'])))
            raw_rom += rom['data']

        if len(raw_rom):
            if len(raw_rom) >= 8192:
                chip_data = raw_rom[0:8192]
                raw_rom = raw_rom[8192:]
            else:
                rest = len(raw_rom) % 8192
                print("chip %2d offset $%04X padding to full chipsize with $%04X bytes " % (chip_header[11], len(raw_rom), 8192 - rest))
                chip_data = raw_rom[0:8192] + bytes(8192 - rest)
                raw_rom = []
            cart.write(chip_header + chip_data)
            chip_header[11] += 1
