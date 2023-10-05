
    * = $1000

    lda $0314
    sta normalirq
    lda $0315
    sta normalirq+1
    sei
    lda #<newirq
    sta $0314
    lda #>newirq
    sta $0315
    cli
    rts

newirq
    pha
    lda $01
    pha
    lda #$15
    sta $01

    lda #>returnirq
    pha
    lda #<returnirq
    pha
    php
    jmp chainirq
;   jmp ($fffe)		; use this if IRQ was setup in RAM at $FFFE

chainirq
    ; IRQ run with #$15 in $01
    rti

returnirq

    pla
    sta $01
    pla
    jmp (normalirq)
;   jmp $ea7e		; use this to skip kernal stuff

normalirq
    .byte $12, $34

