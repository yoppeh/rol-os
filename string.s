;
; string.s
;
; String manipulation routines.
;

.include "rol.i"

.include "math.i"
.include "string.i"


.code


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

string_length:

@strptr = r0
@result = r1

    pha
    push_reg r0

    stz @result

    set_acc_8

@l: lda (@strptr)
    beq @exit
    inc @strptr
    bne @c
    inc @strptr + 1
@c: inc @result
    bne @l
    inc @result + 1
    bra @l

@exit:
    set_acc_16
    pull_reg r0
    pla
    rts


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

string_u16_d_str:

    pha
    phx
    phy
    push_reg r0
    push_reg r1

    ldx #0
    lda r0 + 2
    sta r1

@next_digit:
    set_acc_16
    lda #16
    sta r0 + 2
    jsr math_div
    set_acc_8
    clc
    lda r0 + 2
    adc #'0'
    pha
    inx
    lda r0
    ora r0 + 1
    bne @next_digit
    
    ldy #0
@l: pla
    sta (r1), y
    iny
    dex
    bne @l
    lda #0
    sta (r1), y
    set_acc_16

@exit:
    pull_reg r1
    pull_reg r0
    ply
    plx
    pla
    rts


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

string_u16_h_str:

@u16 = r0
@output_ptr = r0 + 2

    pha
    phx
    push_reg r0
    push_reg r1

    set_idx_8
    ldx #4

@n: lda #0
    clc
    rol @u16
    rol
    rol @u16
    rol
    rol @u16
    rol
    rol @u16
    rol
    cmp #10
    bcs @a
    adc #'0'
    bra @s

@a: clc
    adc #'a'

@s: set_acc_8
    sta (@output_ptr)
    set_acc_16
    inc @output_ptr
    dex
    bne @n

    set_acc_8
    lda #0
    sta (@output_ptr)
    set_acc_16
    inc @output_ptr

    set_all_16
    pull_reg r1
    pull_reg r0
    plx
    pla
    rts
