;
; math.s
;

.include "rol.i"
.include "math.i"


;
; math_div
;
;   Divides a 16 bit numerator by a 16 bit denominator, returning a 16 bit
;   quotient and a 16 bit remainder.  All used registers are preserved, except
;   the flags.
;
; Inputs:
;
;   r0 
;       lower 16 bits = numerator, replaced with quotient.
;       upper 16 bits = denominator, replaced with remainder.
;
; Outputs:
;
;   r0
;       lower 16 bits = quotient
;       upper 16 bits = modulus
;
;   cf
;       1 = division by 0 error.
;       0 = success.
;

math_div:

    pha
    phx
    phy

    lda r0
    stz r0
    tax
    beq @exit
    lda r0 + 2
    stz r0 + 2
    ora #$0000
    beq @error

    ldy #1

@d1:
    asl
    bcs @d2
    iny
    cpy #17
    bne @d1

@d2:
    ror

@d4:
    pha
    txa
    sec
    sbc 1, s
    bcc @d3
    tax

@d3:
    rol r0
    pla
    lsr
    dey
    bne @d4

@exit:
    stx r0 + 2
    ply
    plx
    pla
    clc
    rts

@error:
    ply
    plx
    pla
    sec
    rts


;
; math_mul
;
;   Multiplies two 16 bit numbers and returns the 32 bit product. All registers
;   are preserved.
;
; Inputs:
;
;   r0
;       low 16 bits = multiplier, destroyed on exit.
;       high 16 bits = multiplicand, destroyed on exit.
;
;   r1
;       32 bit result.
;

math_mul:

    pha
    php

    stz r1
    stz r1 + 2

    lda r0 + 2
    beq @done

@m1:
    lda r0
    beq @done
    lsr r0
    bcc @m2

    lda r1
    clc
    adc r0 + 2
    sta r1
    bcc @m2
    inc r1 + 2

@m2:
    asl r0 + 2
    bra @m1

@done:
    plp
    pla
    rts