;
; bcd.i
;
; Subroutines for working with BCD numbers.
;

.ifndef _ROL_BCD_I
_ROL_BCD_I = 1


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

.global bcd_bcd8_to_u8


.endif