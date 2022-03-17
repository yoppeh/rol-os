;
; flags.i
;
; 65c816 flags.
;

.ifndef _ROL_FLAGS_I
_ROL_FLAGS_I = 1


CPU_FLAG_N = %10000000 ; negative = 1
CPU_FLAG_O = %01000000 ; overflow = 1
CPU_FLAG_M = %00100000 ; memory/accumulator 1 = 8, 0 = 16
CPU_FLAG_X = %00010000 ; index registers 1 = 8, 0 = 16
CPU_FLAG_D = %00001000 ; decimal mode = 1, 0 = binary
CPU_FLAG_I = %00000100 ; irq disable = 1
CPU_FLAG_Z = %00000010 ; zero = 1
CPU_FLAG_C = %00000001 ; carry = 1


.endif ; _ROL_FLAGS_I