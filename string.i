;
; string.i
;
; String manipulation routines.
;

.ifndef _ROL_STRING_I
_ROL_STRING_I = 1


;
; string_length
;
;   Returns the length of a null-terminated string.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to string.
;
; Output:
;
;   r1
;       lower 16 bits = length of string, not including the null terminator.
;
;   flags are altered.
;

.global string_length

;
; string_u16_d_str
;
;   Converts a 16 bit unsigned integer to its ASCII representation in
;   base 16 (d = "hexadecimal"). All registers are preserved, except the flags.
;
; Input:
;
;   r0
;       lower 16 bits = the 16 bit unsigned integer, preserved on exit.
;       upper 16 bits = pointer to a buffer to hold the ASCII representation,
;           preserved on exit.
;
; Output:
;
;   The buffer pointed to by the upper 16 bits of r0 will contain the ASCII
;   representation of the unsigned 16 bit number in the lower 16 bits of r0.
;   The ASCII string will be null-terminated.
;

.global string_u16_d_str

;
; string_u16_h_str
;
;   Converts a 16 bit unsigned integer to its ASCII representation in
;   base 10 (d = "decimal"). All registers are preserved, except the flags.
;
; Input:
;
;   r0
;       lower 16 bits = the 16 bit unsigned integer, preserved on exit.
;       upper 16 bits = pointer to a buffer to hold the ASCII representation,
;           preserved on exit.
;
; Output:
;
;   The buffer pointed to by the upper 16 bits of r0 will contain the ASCII
;   representation of the unsigned 16 bit number in the lower 16 bits of r0.
;   The ASCII string will be null-terminated.
;

.global string_u16_h_str


.endif ; _ROL_STRING_I