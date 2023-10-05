
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
    ; jsr $ff5b ;Init video
    ldx #$2f
loop
    lda vic_regs_data, x
    sta $d000, x
    dex
    bpl loop
    jsr $e51b

warmstart
    ldx #$00
copy2ram
    lda ramcode,x
    sta $0380,x
    inx
    cpx #$80
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
    cli
    jmp $0400



    * = $8100

init_read
    ; x contains track
    ; y contains sector
    stx $3cdd           ; original instruction on $3BF8
    sty $3cde

    ; Adjust raster IRQ settings to compensate for extra code
    dec $0ce8           ; $42  next ISR switch to bitmap mode
    dec $0d96           ; $4F
    dec $0dd4           ; $59
    dec $0e22           ; $63
    dec $0e60           ; $6D
    dec $0eae           ; $77
    dec $0eec           ; $81
    dec $0f3a           ; $8B
    dec $0f78           ; $95
    dec $0fc6           ; $9F
    dec $1004           ; $A9
    dec $1052           ; $B1
    dec $1090           ; $BD
    dec $10de           ; $C3  next ISR switches to text mode
    dec $113a           ; $FB

    ; locate requested sector on cart
    dex                 ; tracks start at $01 so decrement by 1
    txa
    asl                 ; times 2, we need to lookup in an array of words
    tax
    clc
    lda track_offsets,x
    adc $3cde           ; add sector
    sta $fe
    lda track_offsets+1,x
    adc #$00
    sta $ff

    lda $fe             ; divide offset by 32 to get bank nr.
    pha
    ldx #$05
l2
    ror $ff
    ror a
    dex
    bne l2
    ldx $fd
    cpx #$31            ; disk 1?
    bne isdisk2
    clc
    adc #$05            ; Disk 1 starts at bank 5
    bne init_done
isdisk2
    clc
    adc #$1B            ; Disk 2 starts at bank 27

init_done
    tay
    pla
    and #$1f
    clc
    adc #$80

    ; a contains offset (high byte)
    ; y contains bank
    rts




    * = $8300

vic_regs_data
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $0b, $00, $00, $00, $00, $c8, $00, $15, $71, $f0, $00, $00, $00, $00, $00
    ;border colors 0,0 and then the spritecolors (just 4 bit anyway).
    .byte $00, $00, $f1, $f2, $f3, $f4, $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $fc, $ff

track_offsets
    .word 0, 21, 42, 63, 84, 105, 126, 147, 168, 189, 210, 231, 252, 273, 294
    .word 315, 336, 357, 376, 395, 414, 433, 452, 471, 490, 508, 526, 544, 562
    .word 580, 598, 615, 632, 649, 666

    * = $83ff
    .byte 0
