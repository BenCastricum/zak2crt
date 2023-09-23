
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
    cli
    jmp $0400

    * = $83ff
    .byte 0
