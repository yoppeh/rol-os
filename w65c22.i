;
; w65c22.i
;
; Driver for the 65c22 VIAs.
;

.ifndef _ROL_W65C22_I
_ROL_W65C22_I = 1


; VIA register offsets
VIA_PORTB = $0000       ; port b data
VIA_PORTA = $0001       ; port a data
VIA_DDRB = $0002        ; data b direction register
VIA_DDRA = $0003        ; data a direction register
VIA_T1CL = $0004        ; timer 1 counter low
VIA_T1CH = $0005        ; timer 1 counter high
VIA_T1LL = $0006        ; timer 1 latches low
VIA_T1LH = $0007        ; timer 1 latches high
VIA_T2CL = $0008        ; timer 2 counter low
VIA_T2CH = $0009        ; timer 2 counter high
VIA_SR = $000a          ; shift register
VIA_ACR = $000b         ; auxilliary control register
VIA_PCR = $000c         ; peripheral control register
VIA_IFR = $000d         ; interrupt flag register
VIA_IER = $000e         ; interrupt enable register
VIA_PORTANH = $000f     ; same as PORTA but with no handshake

; VIA Handshake control values for the peripheral control register
VIA_PCR_CB2_INAE = %00000000    ; input-negative active edge
VIA_PCR_CB2_IIINE = %00100000   ; independent interrupt input-negative edge
VIA_PCR_CB2_IPAE = %01000000    ; input-positive active edge
VIA_PCR_CB2_IIIPE = %01100000   ; independent interrupt input-positive edge
VIA_PCR_CB2_HO = %10000000      ; handshake output
VIA_PCR_CB2_PO = %10100000      ; pulse output
VIA_PCR_CB2_LO = %11000000      ; low output
VIA_PCR_CB2_HI = %11100000      ; high output

VIA_PCR_CB1IC_NAE = %0000000    ; negative active edge
VIA_PCR_CB1IC_PAE = %0000001    ; positive active edge

VIA_PCR_CA2_INAE = %00000000    ; input-negative active edge
VIA_PCR_CA2_IIINE = %00100000   ; independent interrupt input-negative edge
VIA_PCR_CA2_IPAE = %01000000    ; input-positive active edge
VIA_PCR_CA2_IIIPE = %01100000   ; independent interrupt input-positive edge
VIA_PCR_CA2_HO = %10000000      ; handshake output
VIA_PCR_CA2_PO = %10100000      ; pulse output
VIA_PCR_CA2_LO = %11000000      ; low output
VIA_PCR_CA2_HI = %11100000      ; high output

VIA_PCR_CA1IC_NAE = %00000000   ; negative active edge
VIA_PCR_CA1IC_PAE = %00000001   ; positive active edge

; VIA timer control values for the auxilliary register
VIA_ACR_T1_ONESHOT_NO_OUTPUT = %00000000        ; timed interrupt each time t1 loaded - no output
VIA_ACR_T1_CONTINUOUS_NO_OUTPUT = %01000000     ; continuous interrupts - no output
VIA_ACR_T1_ONESHOT_WITH_OUTPUT = %10000000      ; timed interrupt each time t1 is loaded - one shot output
VIA_ACR_T1_CONTINUOUS_WITH_OUTPUT = %11000000   ; continuous interrupts - square wave output
VIA_ACR_T2_INT = %00000000                      ; timed interrupt
VIA_ACR_T2_COUNT = %00100000                    ; count down with pulses on PB6

; VIA shift register control values for the auxilliary register
VIA_ACR_SRC_DISABLE = %00000000         ; disabled
VIA_ACR_SRC_IN_T2SHIFT = %00000100      ; shift in under control of t2
VIA_ACR_SRC_IN_PHI2SHIFT = %00001000    ; shift in under control of phi2
VIA_ACR_SRC_IN_EXTERNSHIFT = %00001100  ; shift in under control of external clock
VIA_ACR_SRC_OUT_FREET2 = %00010000      ; shift out free running at t2 rate
VIA_ACR_SRC_OUT_FREET2CTL = %00010100   ; shift out under control of t2
VIA_ACR_SRC_OUT_FREEPHI2CTL = %00011000 ; shift out under control of phi2
VIA_ACR_SRC_OUT_EXTERNSHIFT = %00011100 ; shift out under control of external clock

VIA_ACR_LATCH_DISABLE = %00000000       ; disable latch
VIA_ACR_LATCH_ENABLE_PB = %00000010     ; enable latching
VIA_ACR_LATCH_ENABLE_PA = %00000001     ; enable latching


; VIA A device.
.global VIAA

; VIA B device.
.global VIAB

; System millisecond counter.
.global ms_counter

; System clock speed in KHz.
.global clock_khz

; Pointer to the IRQ handler for the VIA driver.
.global via_irq


;
; w65c22_init
;
;   Initializes the VIAs and the system timer, which is implemented on VIA A.
;
; Input:
;
;   none
;
; Output:
;
;   flags altered.
;

.global w65c22_init


.endif ; _ROL_W65C22_I