;
; rol.i
;
; Global declarations.
;

.ifndef _ROL_I
_ROL_I = 1

.include "flags.i"


; Processor is assumed to be in 16-bit accumulator/memory and index register
; mode.
.i16
.a16


; Global zero page pseudo-registers.
.globalzp r0, r1, r2, r3, r4, r5, ss


; Sets the processor to 16-bit accumulator/memory and index register mode.
.macro set_all_16
    rep #(CPU_FLAG_M | CPU_FLAG_X)
    .a16
    .i16
.endmacro

; Sets the processor to 8-bit accumulator/memory and index register mode.
.macro set_all_8
    sep #(CPU_FLAG_M | CPU_FLAG_X)
    .a8
    .i8
.endmacro

; Sets the processor to 16-bit accumulator/memory mode. Index registers are
; left unchanged.
.macro set_acc_16
    rep #CPU_FLAG_M
    .a16
.endmacro

; Sets the processor to 16-bit index mode. Accumulator/memory is left 
; unchanged.
.macro set_idx_16
    rep #CPU_FLAG_X
    .i16
.endmacro

; Sets the processor to 8-bit accumulator/memory mode. Index registers are
; left unchanged.
.macro set_acc_8
    sep #CPU_FLAG_M
    .a8
.endmacro

; Sets the processor to 8-bit index register mode. Accumulator/memory is left
; unchanged.
.macro set_idx_8
    sep #CPU_FLAG_X
    .i8
.endmacro


; Macro to push pseudo-register onto the software stack. This macro will result
; in the change of the accumulator, it should be saved if needed. The macro 
; assumes 16-bit accumulator/memory mode.
.macro push_reg reg
    dec ss
    lda reg + 2
    sta (ss)
    dec ss
    dec ss
    lda reg
    sta (ss)
    dec ss
.endmacro

; Macro to pull pseudo-register from the software stack. This macro will result
; in the change of the accumulator, it should be saved if needed. The macro 
; assumes 16-bit accumulator/memory mode.
.macro pull_reg reg
    inc ss
    lda (ss)
    sta reg
    inc ss
    inc ss
    lda (ss)
    sta reg + 2
    inc ss
.endmacro


.endif ; _ROL_I