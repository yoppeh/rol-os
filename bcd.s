;
; bcd.s
;
; Subroutines for working with BCD numbers.
;

.include "rol.i"
.include "bcd.i"


;
; bcd_bcd8_to_u8
;
;   Converts an 8-bit (2 decimal digits) BCD number to an 8-bit binary number.
;   All registers are preserved on rts, including flags.
;
; Input:
;
;   r0
;       lower 8 bits = 8-bit BCD number (00 to 99)
;
; Output:
;
;   r0 
;       lower 8 bits = conversion of input to 8-bit binary number.
;

bcd_bcd8_to_u8:

@bcd_value = r0
@result = r0
    
    php
    pha

    set_acc_8

    lda @bcd_value
    swa
    lda @bcd_value
    stz @result
    and #$f0
    beq @n
    clc
    ror a
    ror a
    ror a
    and #$1e
    sta @result
    asl a
    asl a
    and #$78
    clc
    adc @result
    sta @result
@n: swa
    and #$0f
    clc
    adc @result
    sta @result

    set_acc_16

    pla
    plp
    rts
