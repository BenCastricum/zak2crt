
    * = $0400

    lda $d011		; wait for VIC to draw borders 
    bpl *-3

    ; Adjust raster IRQ settings to compensate for extra code
    inc $0ce8
    inc $0d96
    inc $0dd4
    inc $0e22
    inc $0e60
    inc $0eae
    inc $0eec
    inc $0f3a
    inc $0fc8
    inc $1004
    inc $1052
    inc $1090
    inc $10de
    inc $113a

    ; redirect ISR
    lda #<isrpre
    sta $0314
    sta $0316
    lda #>isrpre
    sta $0315
    sta $0317
    lda #$17
    sta $01

    inc $d020
    jmp *-3

isrpre
    pha
    lda $01
    pha
    lda #$15
    sta $01

    lda #>isrpost
    pha
    lda #<isrpost
    pha
    php
    jmp ($fffe)

isrpost
    pla
    sta $01
    pla
    jmp $ea7e

