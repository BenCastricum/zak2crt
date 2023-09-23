
    * = $3BF8


    stx $3cdd		; original instruction on $3BF8
    sty $3cde
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

    lda $fe             ; divide offset by 32 to get bank nr.
    pha
    ldx #$05
l2
    ror $ff
    ror a
    dex
    bne l2
    ldx $FE7B
    cpx #$31		; disk 1?
    bne check2
    clc
    adc #$05		; Disk 1 starts at bank 5
    bcc setbank
check2
    cpx #$32		; disk 2?
    bne error
    clc
    adc #$1B		; Disk 2 starts at bank 27

setbank
    sei
    sta $de00
    pla
    and #$1f
    clc
    adc #$80
    sta $ff
    ldy #$00
    sty $fe
    lda $01
    pha
    lda #$37
    sta $01
l3
    lda ($fe),y
    sta $0300,y
    iny
    bne l3

    pla
    sta $01
    lda #$80		; hide cartridge banks
    sta $de00
    cli

    clc			; Clear Carry bit indicates successful read
    rts

error
    lda #$03
    sta $d020
    jmp *-3



track_offsets
    .word 0, 21, 42, 63, 84, 105, 126, 147, 168, 189, 210, 231, 252, 273, 294
    .word 315, 336, 357, 376, 395, 414, 433, 452, 471, 490, 508, 526, 544, 562
    .word 580, 598, 615, 632, 649, 666
