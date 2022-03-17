;
; mem.s
;

.include "rol.i"

.include "mem.i"


.code


;
; mem_copy_dec
;
;   Copies a block of memory from a source location to a target location with
;   decrementing address pointers. If the memory areas overlap, this will copy
;   the source nondestructively to the target if the target is at a higher
;   address than the source.
;
; Input:
;
;   r0
;       lower 16 bits = the source address of the end of the block.
;       upper 16 bits = the target address of the end of the block.
;   r1
;       lower 16 bits = number of bytes to copy.
;
; Output:
;
;   flags modified.
;

mem_copy_dec:

    php
    pha
    phx
    phy

    lda r1
    beq @exit
    dec a

    ldx r0
    ldy r0 + 2
    mvp #0, #0

@exit:
    ply
    plx
    pla
    plp
    rts


;
; mem_copy_inc
;
;   Copies a block of memory from a source location to a target location with
;   incrementing address pointers. If the memory areas overlap, this will copy
;   the source nondestructively to the target if the source is at a higher 
;   address than the target.
;
; Input:
;
;   r0
;       lower 16 bits = the source address of the start of the block.
;       upper 16 bits = the target address of the start of the block.
;   r1
;       lower 16 bits = number of bytes to copy.
;
; Output:
;
;   flags modified.
;

mem_copy_inc:

    php
    pha
    phx
    phy

    lda r1
    beq @exit
    dec a

    ldx r0
    ldy r0 + 2
    mvn #0, #0

@exit:
    ply
    plx
    pla
    plp
    rts


;
; mem_zero
;
;   Fills a block of memory with 0x00.
;
; Input:
;
;   r0
;       lower 16 bits = the target address.
;       upper 16 bits = size of the block to fill.
;
; Output:
;
;   flags modified.
;

mem_zero:

    php
    pha
    phx
    phy

    lda r0 + 2
    cmp #0
    beq @exit

    set_acc_8
    lda #0
    sta (r0)
    set_acc_16

    ldx r0
    ldy r0
    iny
    lda r0 + 2
    cmp #1
    beq @exit
    dec
    dec

    mvn #0, #0

@exit:
    ply
    plx
    pla
    plp
    rts
