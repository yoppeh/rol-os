;
; sc28l92.s
;
; Routines for using the sc28l92 UART.
;

.include "rol.i"

.include "sc28l92.i"
.include "w65c22.i"


.segment "UART"

UART:   .res 16


.code


;
; sc28l92_init
;
;   Initializes the sc28l92 UART.
;
; Input:
;
;   none
;
; Output:
;
;   Flags are used to return status.
;	    cf = 0 on success.
;	    cf = 1 on failure.
;

sc28l92_init:

    pha

    set_all_8

    ; reset sc28l92 uart receiver, transmitter and error
    lda #SC28L92_CR_RESET_RECEIVER
    sta UART + SC28L92_CRA
    lda #SC28L92_CR_RESET_TRANSMITTER
    sta UART + SC28L92_CRA
    lda #SC28L92_CR_RESET_ERROR
    sta UART + SC28L92_CRA

    ; point to uart mr0a
    lda #SC28L92_CR_SET_MR_POINTER_0
    sta UART + SC28L92_CRA

    ; setup mode register a on uart
    ; mr0a
    lda #(SC28L92_MR0_RXWATCHDOG_DISABLE | SC28L92_MR0_FIFOSIZE_16 | SC28L92_MR0_BAUD_NORMAL)
    sta UART + SC28L92_MRA

    ; uart mr1a
    lda #(SC28L92_MR1_RXRTS_OFF | SC28L92_MR1_PARITY_NONE | SC28L92_MR1_DATA_8)
    sta UART + SC28L92_MRA
	
    ; uart mr2a
    lda #(SC28L92_MR2_CHANNEL_MODE_NORMAL | SC28L92_MR2_CTS_OFF | SC28L92_MR2_RTS_OFF | SC28L92_MR2_STOP_BIT_1)
    sta UART + SC28L92_MRA

    ; setup uart clock select register a (9600 baud)
    lda #%11001100
    sta UART + SC28L92_CSRA

    ; enable uart send/receive
    lda #(SC28L92_CR_ENABLE_TX | SC28L92_CR_ENABLE_RX)
    sta UART + SC28L92_CRA

    lda #%10000000
    sta UART + SC28L92_ACR

    ; should get $0c
    lda UART + SC28L92_SRA
    cmp #$0c
    clc
    beq @x

    sec

@x: set_all_16

    pla
    rts


;
; Transmits a 0-terminated string over the UART.
;
; inputs:
;
;   r0 - pointer to string to transmit.
;
; outputs:
;
;   none
;

sc28l92_tx_string:

    pha
    push_reg r0

    set_all_8

@n: lda (r0)
	ora #$00
	beq @x
    xba
@w:	lda UART + SC28L92_SRA
	and #SC28L92_SR_TXRDY
	beq @w
	xba
	sta UART + SC28L92_TXFIFOA
    inc r0
    bne @n
    inc r0 + 1
	bra @n

@x: set_all_16

    pull_reg r0
    pla
    rts