;
; sc28l92.i
;
; Routines for using the sc28l92 UART.
;

.ifndef _ROL_SC28L92_I
_ROL_SC28L92_I = 1


; register offsets from base address
SC28L92_MRA = $0000         ; mode register a (mr0a, mr1a, mr2a) (read/write)
SC28L92_SRA = $0001         ; status register a (read)
SC28L92_CSRA = $0001        ; clock select register a (write)
SC28L92_CRA = $0002         ; command register a (write)
SC28L92_RXFIFOA = $0003     ; rx holding register a (read)
SC28L92_TXFIFOA = $0003     ; tx holding register a (write)
SC28L92_IPCR = $0004        ; input port change register (read)
SC28L92_ACR = $0004         ; auxiliary control register (write)
SC28L92_ISR = $0005         ; interrupt status register (read)
SC28L92_IMR = $0005         ; interrupt mask register (write)
SC28L92_CTU = $0006         ; counter/timer upper (read)
SC28L92_CTPU = $0006        ; c/t upper preset register (write)
SC28L92_CTL = $0007         ; counter/timer lower (read)
SC28L92_CTPL = $0007        ; c/t lower preset register (write)
SC28L92_MRB = $0008         ; mode register b (mr0b, mr1b, mr2b) (read/write)
SC28L92_SRB = $0009         ; status register b (read)
SC28L92_CSRB = $0009        ; clock select register b (write)
SC28L92_CRB = $000a         ; command register b (write)
SC28L92_RXFIFOB = $000b     ; rx holding register b (read)
SC28L92_TXFIFOB = $000b     ; tx holding register b (write)
SC28L92_MRR = $000c         ; miscellaneous register (read/write)
SC28L92_IPR = $000d         ; input port register (read)
SC28L92_OPCR = $000d        ; output port configuration register (write)
SC28L92_STARTCC = $000e     ; start counter command (read)
SC28L92_SOPR = $000e        ; set output port bits command (write)
SC28L92_STOPCC = $000f      ; stop counter command (read)
SC28L92_ROPR = $000f        ; reset output port bits command (write)

; command register commands
SC28L92_CR_NOP = %00000000
SC28L92_CR_RESET_MR = %00010000
SC28L92_CR_RESET_RECEIVER = %00100000
SC28L92_CR_RESET_TRANSMITTER = %00110000
SC28L92_CR_RESET_ERROR = %01000000
SC28L92_CR_RESET_BRK_CHANGE_INT = %01010000
SC28L92_CR_START_BREAK = %01100000
SC28L92_CR_STOP_BREAK = %01110000
SC28L92_CR_ASSERT_RTSN = %10000000
SC28L92_CR_NEGATE_RTSN = %10010000
SC28L92_CR_SET_TIMEOUT_MODE_ON = %10100000
SC28L92_CR_SET_MR_POINTER_0 = %10110000
SC28L92_CR_SET_TIMEOUT_MODE_OFF = %11000000
SC28L92_CR_POWER_DOWN_MODE_ON = %11100000
SC28L92_CR_POWER_DOWN_MODE_OFF = %11110000
SC28L92_CR_DISABLE_TX = %00001000
SC28L92_CR_ENABLE_TX = %00000100
SC28L92_CR_DISABLE_RX = %00000010
SC28L92_CR_ENABLE_RX = %00000001

; mode register 0 
SC28L92_MR0_RXWATCHDOG_ENABLE = %10000000
SC28L92_MR0_RXWATCHDOG_DISABLE = %00000000
SC28L92_MR0_RXINT = %01000000
SC28L92_MR0_TXINT = %00110000
SC28L92_MR0_FIFOSIZE_16 = %00001000
SC28L92_MR0_FIFOSIZE_8 = %00000000
SC28L92_MR0_BAUD_NORMAL = %00000000
SC28L92_MR0_BAUD_EXTENDED_1 = %000000001
SC28L92_MR0_BAUD_EXTENDED_2 = %000000100

; mode register 1
SC28L92_MR1_RXRTS_ON = %10000000
SC28L92_MR1_RXRTS_OFF = %00000000
SC28L92_MR1_RXINT = %01000000
SC28L92_MR1_ERROR_MODE_CHARACTER = %00000000
SC28L92_MR1_ERROR_MODE_BLOCK = %00100000
SC28L92_MR1_PARITY_ON = %00000000
SC28L92_MR1_PARITY_FORCE = %00001000
SC28L92_MR1_PARITY_NONE = %00010000
SC28L92_MR1_PARITY_MDSM = %00011000
SC28L92_MR1_PARITY_EVEN = %00000000
SC28L92_MR1_PARITY_ODD = %00000100
SC28L92_MR1_DATA_5 = %00000000
SC28L92_MR1_DATA_6 = %00000001
SC28L92_MR1_DATA_7 = %00000010
SC28L92_MR1_DATA_8 = %00000011

; mode register 2
SC28L92_MR2_CHANNEL_MODE_NORMAL = %00000000
SC28L92_MR2_CHANNEL_MODE_AUTOECHO = %01000000
SC28L92_MR2_CHANNEL_MODE_LOOPBACK_L = %10000000
SC28L92_MR2_CHANNEL_MODE_LOOPBACK_R = %11000000
SC28L92_MR2_RTS_ON = %00100000
SC28L92_MR2_RTS_OFF = %00000000
SC28L92_MR2_CTS_ON = %00010000
SC28L92_MR2_CTS_OFF = %00000000
SC28L92_MR2_STOP_BIT_1 = %00000111
SC28L92_MR2_STOP_BIT_2 = %00001111

; status register
SC28L92_SR_BREAK = %10000000
SC28L92_SR_FRAMING_ERROR = %01000000
SC28L92_SR_PARITY_ERROR = %00100000
SC28L92_SR_OVERRUN_ERROR = %00010000
SC28L92_SR_TXEMT = %00001000
SC28L92_SR_TXRDY = %00000100
SC28L92_SR_RXFULL = %00000010
SC28L92_SR_RXRDY = %00000001


; The UART device
.global UART


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

.global sc28l92_init

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

.global sc28l92_tx_string


.endif ; _ROL_SC28L92_I