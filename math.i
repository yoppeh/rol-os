;
; math.i
;

.ifndef _ROL_MATH_I
_ROL_MATH_I = 1


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

.global math_div

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

.global math_mul


.endif