;
; ascii.i
;
; The ASCII control characters.
;

.ifndef _ROL_ASCII_I
_ROL_ASCII_I = 1


ASCII_NUL = 0   ; null
ASCII_SOH = 1   ; start of heading
ASCII_STX = 2   ; start of text
ASCII_ETX = 3   ; end of text
ASCII_EOT = 4   ; end of transmission
ASCII_ENQ = 5   ; enquiry
ASCII_ACK = 6   ; acknowledge
ASCII_BEL = 7   ; bell
ASCII_BS = 8    ; backspace
ASCII_TAB = 9   ; horizontal tab
ASCII_LF = 10   ; line feed (newline)
ASCII_VT = 11   ; vertical tab
ASCII_FF = 12   ; form feed
ASCII_CR = 13   ; carriage return
ASCII_SO = 14   ; shift out
ASCII_SI = 15   ; shift in
ASCII_DLE = 16  ; data link escape
ASCII_DC1 = 17  ; device control 1
ASCII_DC2 = 18  ; device control 2
ASCII_DC3 = 19  ; device control 3
ASCII_DC4 = 20  ; device control 4
ASCII_NAK = 21  ; negative acknowledge
ASCII_SYN = 22  ; synchronous idle
ASCII_ETB = 23  ; end of transmission block
ASCII_CAN = 24  ; cancel
ASCII_EM = 25   ; end medium
ASCII_SUB = 26  ; substitute
ASCII_ESC = 27  ; escape
ASCII_FS = 28   ; file separator
ASCII_GS = 29   ; group separator
ASCII_RS = 30   ; record separator
ASCII_US = 31   ; unit separator


.endif ; _ROL_ASCII_I