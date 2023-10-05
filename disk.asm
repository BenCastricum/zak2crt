
    * = $3BF8


    lda $d011           ; wait for VIC to draw borders
    bpl *-3

    lda $fe7b		; save requested disk
    sta $fd

    ; redirect ISR
    lda #<isrpre
    sta $0314
    sta $0316
    lda #>isrpre
    sta $0315
    sta $0317

    lda #$00
    sta $de00		; we switch in bank 0 for code

    lda #$17
    sta $01

    ; $fd contains disk (either '1', or '2')
    ; x contains track
    ; y contains sector
    jsr $8100		; call init_read from loader.asm
    ; y contains bank
    ; a contains offset (high byte)

    sty $de00
    sta romloc1+2
    sta romloc2+2
    sta romloc3+2
    ldy #$18

romloc1
    lda $8000,y         ; 5 cycles
    sta $0300,y         ; 5 cycles
    iny                 ; 2 cycles
    bne romloc1         ; 3 cycles

    ldy #$13
romloc2
    lda $8000,y         ; 5 cycles
    sta $0300,y         ; 5 cycles
    dey                 ; 2 cycles
    bpl romloc2         ; 3 cycles

    ; sector copy almost done, restore compensation
    lda $d011
    bpl *-3

    inc $0ce8		; $42
    inc $0d96		; $4F
    inc $0dd4		; $59
    inc $0e22		; $63
    inc $0e60		; $6D
    inc $0eae		; $77
    inc $0eec		; $81
    inc $0f3a		; $8B
    inc $0f78		; $95
    inc $0fc6		; $9F
    inc $1004		; $A9
    inc $1052		; $B1
    inc $1090		; $BD
    inc $10de		; $C3
    inc $113a		; $FB

    ; copy the last 4 bytes
    ldy #$14
    ldx #$04
    sei
romloc3
    lda $8000,y         ; 5 cycles
    sta $0300,y         ; 5 cycles
    iny                 ; 2 cycles
    dex                 ; 2 cycles
    bne romloc3         ; 3 cycles


    lda #$15
    sta $01
    cli
    clc			; Clear Carry bit indicates successful read
    rts

error
    lda #$02
    sta $d020
    jmp *-3

; The screen is rendered line-by-line and each line takes exactly 63 clock cycles.

; code from kernal rom 
;   pha			; 3 cycles
;   txa			; 2 cycles
;   pha			; 3 cycles
;   tya			; 2 cycles
;   pha			; 3 cycles
;   tsx			; 2 cycles
;   lda $0104,x		; 4 cycles
;   and #$10		; 2 cycles
;   beq $ff58		; 3 cycles (assuming normal interrupt)
;   jmp ($0316)		; 5 cycles
;   jmp ($0314)		; 5 cycles
; this codes adds 34 cycles

isrpre
    lda $01		; 2 cycles
    pha                 ; 3 cyccle
    lda #$15		; 2 cycles
    sta $01		; 3 cycles
    lda #>isrpost	; 2 cycles
    pha			; 3 cycles
    lda #<isrpost	; 2 cycles
    pha			; 3 cycles
    php			; 3 cycles
    jmp ($fffe)		; 5 cycles
; this codes adds 28 cycles

isrpost
    pla
    sta $01
    jmp $ea7e
