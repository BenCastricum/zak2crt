
    * = $8000

    .word coldstart            ; coldstart vector
    .word warmstart            ; warmstart vector
    .byte $C3,$C2,$CD,$38,$30  ; "CBM8O". Autostart string


coldstart
    sei
    stx $d016
    jsr $fda3 ;Prepare IRQ

    ; we use this now as delay, to allow the disk to initialize
    ; it should be possible to remove this later
    jsr $fd50
    ; faster replacement code for jsr $fd50 (init memory)
    lda #$00
    ldx #$fc
loop0
    sta $01,X
    sta $01ff,X
    sta $02ff,X
    dex
    bne loop0
    ldx #$00
    ldy #$80
    jsr $fd8d ; init basic bottom and top
    ldx #$3C
    ldy #$03
    stx $B2
    sty $B3

    jsr $fd15 ;Init I/O
    ; TODO , replace jsr below wit http://downloads.rgcd.co.uk/projects/c64/howto.txt
    ; register documentation : http://www.zimmers.net/cbmpics/cbm/c64/vic-ii.txt
    jsr $ff5b ;Init video

warmstart
    ; wait for vsync
    lda $d011
    and #$80
    ora $d012
    bne warmstart

    sta $d020
    sta $d011
    tay
copy2ram
    lda ramcode,y
    sta $0380,y
    lda sectorcode,y
    sta $F000,Y
    iny
    cpy #$80
    bne copy2ram
    jmp $0380

ldr_src = $8400 ; in bank 0
ldr_dst = $0400
ldr_size = $9C

ramcode
    lda #>ldr_src
    sta $fd
    lda #>ldr_dst
    sta $ff
    ldy #$00
    sty $fc
    sty $fe
    sty $fb
    ldx #ldr_size
loop1
    lda ($fc),y
    sta ($fe),y
    dey
    bne loop1
    inc $fd
    inc $ff
    lda $fd
    cmp #$a0            ; end of current bank?
    bne next
    lda #$80            ; next bank
    sta $fd
    inc $fb
    lda $fb
    sta $de00
next
    dex
    bne loop1
    lda #$80		; hide cartridge banks
    sta $de00
    lda #$4c		; insert jmp $f000
    sta $3bf8
    lda #$00
    sta $3bf9
    lda #$f0
    sta $3bfa
    cli
    jmp $0400

sectorcode
    stx $3cdd		; original instruction on $3BF8
    dex                 ; tracks start at $01 so decrement by 1
    txa
    asl			; times 2, we need to lookup in an array of words
    tax
    clc
    lda track_offsets,x
    adc $3CDE		; add sector
    sta $FE
    lda track_offsets+1,x
    adc #$00
    sta $FF
    ldx $3cdd
    jmp $3bfb
; we still need to add the offset of the disk image in the rom





track_offsets
    .word 0, 21, 42, 63, 84, 105, 126, 147, 168, 189, 210, 231, 252, 273, 294
    .word 315, 336, 357, 376, 395, 414, 433, 452, 471, 490, 508, 526, 544, 562
    .word 580, 598, 615, 632, 649, 666

    * = $83ff
    .byte 0
