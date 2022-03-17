;
; 65c22.s
;
; Driver for the 65c22 VIAs.
;

.include "rol.i"

.include "ds1501.i"
.include "math.i"
.include "w65c22.i"


.segment "VIA"

VIAA:	.res 32
VIAB:	.res 32


.bss

ms_counter: .res 4
clock_khz: .res 2


.data

via_irq: .addr timer_irq


.code


;
; timer_init
;
;   Private Subroutine.
;
;   Initializes the system millisecond counter. We setup VIA A, timer 1 to 
;   increment ms_counter every 1000 clock pulses. We then let it run as close
;   to 1 second as we can, using the RTC to measure 1 second. Then we shut off
;   the timer 1 counter. At that point, ms_counter has the number of counts to
;   set timer 1 to in order to get one count every millisecond.
;
; Input:
;
;   none
;
; Output:
;
;   flags altered.
;

timer_init:

    pha
    phx
    phy

	; Clear millisecond counter
	stz ms_counter
    stz ms_counter + 2

    set_all_8

    lda RTC + DS1501_CONTROL_B
    sta VIAA + VIA_PORTA

	; Set timer 1 on via 0 to free run mode with continuous interrupts.
	lda #VIA_ACR_T1_CONTINUOUS_NO_OUTPUT
	sta VIAA + VIA_ACR

	; Set timer 1 latches to count down from 1000 then interrupt.
	lda #$e8
	sta VIAA + VIA_T1CL

    ; Need bcd arithmetic for rtc seconds
    sed
    ; Preload setup values to spare clock cycles later
    ldx #%11000000      ; interrupt setup
    ldy #$03            ; high byte of "1000"

	; Make sure rtc seconds is well enough below 00, else wait for 00
@w:	lda RTC + DS1501_SECOND
    sta VIAA + VIA_PORTB
	cmp #$58
	bcs @w

	; Store next rtc seconds so we can get close to the beginning of
	; the next second
	inc a
@n: cmp RTC + DS1501_SECOND
    bne @n

	; Enable timer 1 interrupts
	stx VIAA + VIA_IER
	; Store the remainder of the countdown in the timer counter msb to start
	; it going.
	sty VIAA + VIA_T1CH

	; Wait for one second
@f: cmp RTC + DS1501_SECOND
	beq @f

	; Stop timer 1 interrupts
    sei
	lda #%01000000
	sta VIAA + VIA_IER

    cld

    ; The amount ms_counter was incremented gives us the speed of the system
    ; oscillator in khz. that value is stored in clock_khz for use by other
    ; parts of the system and is loaded into VIA A's timer 1 counter as the
    ; new divisor, effectively causing an interrupt to be generated every
    ; millisecond.
    lda ms_counter
    stz ms_counter
    sta VIAA + VIA_T1CL
    sta clock_khz
    lda ms_counter + 1
    sta clock_khz + 1
    stz ms_counter + 1
    stz ms_counter + 2
    stz ms_counter + 3
    sta VIAA + VIA_T1CH

    ; Reenable timer 1 interrupts (mask is still in x)
    stx VIAA + VIA_IER

    set_all_16

    ; Round up the clock value.
    push_reg r0
    push_reg r1
@i: lda clock_khz
    sta r0
    lda #100
    sta r0 + 2
    jsr math_div
    lda r0 + 2
    beq @exit
    inc clock_khz
    bra @i

@exit:
    pull_reg r1
    pull_reg r0

    cli

    ply
    plx
    pla
	rts


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

w65c22_init:

    pha

    ; Set both ports on all VIAs to outputs.
    lda #$ffff
    sta VIAA + VIA_DDRB
    sta VIAB + VIA_DDRB

    set_acc_8

    ; Disable interrupts on all VIAs.
    lda #$7f
    sta VIAA + VIA_IER
    sta VIAB + VIA_IER

    ; Turn off latches and timers.
    lda #0
  	sta VIAA + VIA_ACR
    sta VIAB + VIA_ACR

    set_acc_16
    
    ; initialize the system millisecond timer.
    jsr timer_init

    pla
    rts


;
; timer_irq
;
;   This is the VIA interrupt handler. It handles updating the system clock
;   using VIA A's timer 1. During initialization, it's also used to calculate
;   the speed of the system oscillator (which is essentially the same function
;   as implementing the system clock, with different divisors).
;
; Input:
;
;   none
;
; Output:
;
;   none
;

timer_irq:

    pha

    set_acc_8

    ; Clear the interrupt flag on VIA A.
    lda VIAA + VIA_IFR
	and #%01000000
	beq @x
    lda VIAA + VIA_T1CL

    set_acc_16

    ; Increment the system millisecond counter.
    inc ms_counter
    bne @x
    inc ms_counter + 2

@x: set_acc_16
    pla
    rts
