;
; mem.i
;

.ifndef _ROL_MEM_I
_ROL_MEM_I = 1


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

.global mem_copy_dec

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

.global mem_copy_inc 

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

.global mem_zero


.endif ; _ROL_MEM_I