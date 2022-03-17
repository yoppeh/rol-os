;
; rol.s
;

.include "rol.i"
.include "ascii.i"

.include "ds1501.i"
.include "math.i"
.include "mem.i"
.include "sc28l92.i"
.include "string.i"
.include "time.i"
.include "w65c22.i"


.import __DATA_LOAD__, __DATA_RUN__, __DATA_SIZE__
.import __BSS_RUN__, __BSS_SIZE__
.import __SSTACK_START__, __SSTACK_SIZE__
.import __STACK_START__, __STACK_SIZE__


.zeropage

.exportzp r0, r1, r2, r3, r4, r5, ss

; 6 32-bit, general purpose "registers". These can be pushed and pulled to/from
; the software stack with the push_reg and pull_reg macros defined in rol.i.
r0: .res 4
r1: .res 4
r2: .res 4
r3: .res 4
r4: .res 4
r5: .res 4

; Software stack pointer.
ss: .res 2


.segment "SSTACK"


.data

via_led_pattern: .addr $aaaa


.bss

output_str: .res 50
clock_mhz: .res 2
bcd_date: .tag TIME_BCD_T


.code

    .a8
    .i8


reset:

    ; Enable native mode.
    clc
    xce
    
    set_all_16

    ; Setup hardware stack.
    ldx #(__STACK_START__ + __STACK_SIZE__ - 1)
    txs

    ; Setup software stack.
    lda #(__SSTACK_START__ + __SSTACK_SIZE__ - 1)
    sta ss

    ; BCD mode off.
    cld

    jsr init_ram
    
    ; Enable interrupts.
    cli

    ; Initialize hardware.
    jsr ds1501_init
    jsr w65c22_init
    jsr sc28l92_init

    lda via_led_pattern
    sta VIAA + VIA_PORTB
    sta VIAB + VIA_PORTB

    jsr print_startup_text

    ; Toggle LEDs.
@l: lda via_led_pattern
    sta VIAA + VIA_PORTB
    sta VIAB + VIA_PORTB
    eor #$ffff
    sta via_led_pattern
@i: lda ms_counter
    cmp #500
    bcc @i
    stz ms_counter
    stz ms_counter + 2
    bra @l


init_ram:

    ; Copy initialized data to ram.
    lda #__DATA_LOAD__
    sta r0
    lda #__DATA_RUN__
    sta r0 + 2
    lda #__DATA_SIZE__
    sta r1
    jsr mem_copy_inc

    ; Zero out BSS.
    lda #__BSS_RUN__
    sta r0
    lda #__BSS_SIZE__
    sta r0 + 2
    jsr mem_zero

    rts


print_startup_text:

    lda #welcome_str
    sta r0
    jsr sc28l92_tx_string

    ; Set date/time on RTC from TIME_BCD_T variable bcd_date.
    lda #bcd_date
    sta r0
    lda #$2220
    sta (r0)
    inc r0
    inc r0
    lda #$1503
    sta (r0)
    inc r0
    inc r0
    lda #$3100
    sta (r0)
    inc r0
    inc r0
    lda #$0200
    sta (r0)
    lda #bcd_date
    sta r0
    jsr ds1501_set_date

    ; Get date/time from RTC into TIME_BCD_T variable bcd_date.
    lda #bcd_date
    sta r0
    jsr ds1501_read_date

    ; Format the date/time returned above for output.
    lda #startup_date_format_str
    sta r0 + 2
    lda #output_str
    sta r1
    jsr time_format_date

    ; Output the formatted date/time.
    lda #output_str
    sta r0
    jsr sc28l92_tx_string

    ; Calculate system oscillator frequency in MHz.
    lda clock_khz
    sta r0
    lda #1000
    sta r0 + 2
    jsr math_div
    
    ; Display system clock frequency.
    push_reg r0
    lda #output_str
    sta r0 + 2
    jsr string_u16_d_str
    lda #output_str
    sta r0
    jsr sc28l92_tx_string
    lda #decimal_str
    sta r0
    jsr sc28l92_tx_string
    pull_reg r0
    lda r0 + 2
    sta r0
    lda #output_str
    sta r0 + 2
    jsr string_u16_d_str
    lda #output_str
    sta r0
    jsr sc28l92_tx_string
    lda #mhz_str
    sta r0
    jsr sc28l92_tx_string
    lda #lf_str
    sta r0
    jsr sc28l92_tx_string

    ; Get RTC battery status
    lda #rtc_battery_str
    sta r0
    jsr sc28l92_tx_string
    jsr ds1501_read_batteries
    lda r0
    and #DS1501_VBAT_MASK
    beq @b
    lda #ok_str
    sta r0
    bra @s
@b: lda #low_str
    sta r0
@s: jsr sc28l92_tx_string
    lda #lf_str
    sta r0
    jsr sc28l92_tx_string
    
    rts


;
; Handlers for emulation mode vectors.
;

copv8:
    rti


abort8:
    rti


nmi8:
    rti


irq8:
    rti


;
; Handlers for native mode vectors.
;

copv:
    rti


break:
    rti


abort:
    rti


nmi:
    rti


;
; irq
;
;   This is the system IRQ handler.
;

irq:

    set_all_16
    pha
    phx

    ldx #$0000
    lda via_irq
    beq @x
    jsr (via_irq, x)
@x: plx
    pla
    rti


.rodata


decimal_str:
    .byte ".", 0

lf_str:
    .byte ASCII_LF, 0

low_str:
    .byte "low", 0

mhz_str:
    .byte " MHz", 0

ok_str:
    .byte "OK", 0

rtc_battery_str:
    .byte "RTC battery ", 0

startup_date_format_str:
    .byte "Today is %A, %Y-%m-%d %H:%M:%S%n", 0

welcome_str:
	.byte ASCII_ESC, "[H", ASCII_ESC, "[J", "ROL Shell Version 1.00", ASCII_LF, 0


;
; Vector table
;
; Starts at ffe0 and fills the remainder of ROM. See rol-ld65.cfg.
;

.segment "VECTORS"

    .addr $0000
    .addr $0000
    .addr copv
    .addr break
    .addr abort
    .addr nmi
    .addr $0000
    .addr irq
    .addr $0000
    .addr $0000
    .addr copv8
    .addr $0000
    .addr abort8
    .addr nmi8
    .addr reset
    .addr irq8
