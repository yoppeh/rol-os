;
; ds1501.s
;
; Code for controlling the ds1501 real time clock.
;

.include "rol.i"

.include "ds1501.i"
.include "time.i"


.segment "RTC"

RTC: .res 20


.code


;
; ds1501_init
;
;   Initializes the ds1501 real time clock.
;
; Input:
;
;   None.
;
; Output:
;
;   None.
;

ds1501_init:

    pha
    php

    set_acc_8

    lda #(DS1501_CTL_B_TE_ON | DS1501_CTL_B_CS_OFF | DS1501_CTL_B_BME_OFF | DS1501_CTL_B_TPE_OFF | DS1501_CTL_B_TIE_OFF | DS1501_CTL_B_KIE_OFF | DS1501_CTL_B_WDE_OFF | DS1501_CTL_B_WDS_OFF)
    sta RTC + DS1501_CONTROL_B  ; sets configuration defined above
    lda RTC + DS1501_CONTROL_A
    and #%11000000
    sta RTC + DS1501_CONTROL_A
    lda RTC + DS1501_MONTH
    and #%01011111
    sta RTC + DS1501_MONTH

    plp
    .a16
    .i16
    pla
    rts


;
; ds1501_read_batteries
;
;   Reads the status bits for vbat and vbaux in the Control A register. The
;   status of the batteries is returned as VB_VBAT_xxx/VB_VBAUX_xxx values
;   defined above.
;
; Input:
;
;   none
;
; Output:
;
;   r0
;       lower 8 bits = Battery state. The appropriate VB_VBAT_xx and 
;           VB_VBAUX_xx values are ORed together and returned. VB_VBAT_MASK
;           and VB_VBAUX_MASK can be used to isolate the appropriate
;           flags, or both can be tested simultaneously with 
;           "VB_VBAT_OK | VB_VBAUX_OK".
;

ds1501_read_batteries:

@result = r0

    pha
    php

    set_acc_8
    lda RTC + DS1501_CONTROL_A
    ror a
    ror a
    ror a
    ror a
    ror a
    ror a
    sta @result

    plp
    .i16
    .a16
    pla
    rts


;
; ds1501_read_date
;
;   Reads the current time from the RTC and stores it as a TIME_BCD_T 
;   struct pointed to by the input parameter.
;
;   Output format:
;
;       (r0 + TIME_BCD_T::century) = [7:4 century 10s digit, 3:0 century 1s digit]
;       (r0 + TIME_BCD_T::year) = [7:4 year 10s digit, 3:0 year 1s digit]
;       (r0 + TIME_BCD_T::month) = [7:4 month 10s digit, 3:0 month 1s digit]
;       (r0 + TIME_BCD_T::day) = [7:4 day 10s digit, 3:0 day 1s digit]
;       (r0 + TIME_BCD_T::hour) = [7:4 hour 10s digit, 3:0 hour 1s digit]
;       (r0 + TIME_BCD_T::minute) = [7:4 minute 10s digit, 3:0 minute 1s digit]
;       (r0 + TIME_BCD_T::second) = [7:4 second 10s digit, 3:0 second 1s digit]
;       (r0 + TIME_BCD_T::dow) = [7:4 0, 3:0 day of week digit]
;
;       Each digit is a 4-bit nybble in the given byte with a value from 0 to
;       10. As an example, "2022-02-27 13:10:00 1" would be represented as:
;
;       (r0 + TIME_BCD_T::century) = $20
;       (r0 + TIME_BCD_T::year) = $22
;       (r0 + TIME_BCD_T::month) = $02
;       (r0 + TIME_BCD_T::day) = $27
;       (r0 + TIME_BCD_T::hour) = $13
;       (r0 + TIME_BCD_T::minute) = $10
;       (r0 + TIME_BCD_T::second) = $00
;       (r0 + TIME_BCD_T::dow) = $01
;
; Input:
;
;   r0
;       lower 16 bits = pointer to TIME_BCD_T struct into which date/time 
;       data will be stored.
;
; Output:
;
;   None.
;

ds1501_read_date:

    .a16
    .i16

@time_ptr = r0

    pha
    php
    push_reg r0

    set_acc_8

    ; Turn off clock updates until we read everything.
    lda RTC + DS1501_CONTROL_B
    pha
    and #DS1501_CTL_B_TE_MASK
    sta RTC + DS1501_CONTROL_B

    ; century
	lda RTC + DS1501_CENTURY
	sta (@time_ptr)
    inc @time_ptr
    bne @y
    inc @time_ptr + 1

    ; year
@y: lda RTC + DS1501_YEAR
    sta (@time_ptr)
    inc @time_ptr
    bne @m
    inc @time_ptr + 1

    ; month
@m: lda RTC + DS1501_MONTH
    and #$1f
    sta (@time_ptr)
    inc @time_ptr
    bne @d
    inc @time_ptr + 1

    ; day
@d: lda RTC + DS1501_DATE
    sta (@time_ptr)
    inc @time_ptr
    bne @h
    inc @time_ptr + 1

    ; hour
@h: lda RTC + DS1501_HOUR
    sta (@time_ptr)
    inc @time_ptr
    bne @i
    inc @time_ptr + 1

    ; minute
@i: lda RTC + DS1501_MINUTE
    sta (@time_ptr)
    inc @time_ptr
    bne @s
    inc @time_ptr + 1

    ; second
@s: lda RTC + DS1501_SECOND
    sta (@time_ptr)
    inc @time_ptr
    bne @w
    inc @time_ptr + 1

    ; day of week
@w: lda RTC + DS1501_DAY
    sta (@time_ptr)
    inc @time_ptr
    bne @exit
    inc @time_ptr + 1

    ; Restore control b register (we modified it above to turn off clock 
    ; updates).
@exit:
    pla
    ora #DS1501_CTL_B_TE_ON
    sta RTC + DS1501_CONTROL_B

    set_acc_16

    pull_reg r0
    plp
    pla
	rts


;
; ds1501_set_date
;
;   Sets the current time from a TIME_BCD_T struct pointed to by the input 
;   parameter.
;
;   Input format:
;
;       (r0 + TIME_BCD_T::century) = [7:4 century 10s digit, 3:0 century 1s digit]
;       (r0 + TIME_BCD_T::year) = [7:4 year 10s digit, 3:0 year 1s digit]
;       (r0 + TIME_BCD_T::month) = [7:4 month 10s digit, 3:0 month 1s digit]
;       (r0 + TIME_BCD_T::day) = [7:4 day 10s digit, 3:0 day 1s digit]
;       (r0 + TIME_BCD_T::hour) = [7:4 hour 10s digit, 3:0 hour 1s digit]
;       (r0 + TIME_BCD_T::minute) = [7:4 minute 10s digit, 3:0 minute 1s digit]
;       (r0 + TIME_BCD_T::second) = [7:4 second 10s digit, 3:0 second 1s digit]
;       (r0 + TIME_BCD_T::dow) = [7:4 0, 3:0 day of week digit]
;
;       Each digit is a 4-bit nybble in the given byte with a value from 0 to
;       10. As an example, "2022-02-27 13:10:00 1" would be represented as:
;
;       (r0 + TIME_BCD_T::century) = $20
;       (r0 + TIME_BCD_T::year) = $22
;       (r0 + TIME_BCD_T::month) = $02
;       (r0 + TIME_BCD_T::day) = $27
;       (r0 + TIME_BCD_T::hour) = $13
;       (r0 + TIME_BCD_T::minute) = $10
;       (r0 + TIME_BCD_T::second) = $00
;       (r0 + TIME_BCD_T::dow) = $01
;
; Input:
;
;   r0
;       lower 16 bits = pointer to TIME_BCD_T struct from which date/time 
;       data will be taken.
;
; Output:
;
;   None.
;

ds1501_set_date:

    .a16
    .i16

@time_ptr = r0

    pha
    php
    push_reg r0

    set_acc_8

    ; Turn off clock updates until we write everything.
    lda RTC + DS1501_CONTROL_B
    pha
    and #DS1501_CTL_B_TE_MASK
    sta RTC + DS1501_CONTROL_B

    ; century
	lda (@time_ptr)
    sta RTC + DS1501_CENTURY
    inc @time_ptr
    bne @y
    inc @time_ptr + 1

    ; year
@y: lda (@time_ptr)
    sta RTC + DS1501_YEAR
    inc @time_ptr
    bne @m
    inc @time_ptr + 1

    ; month
@m: lda RTC + DS1501_MONTH
    and #$e0
    pha
    lda (@time_ptr)
    and #$1f
    ora 1, s
    sta RTC + DS1501_MONTH
    pla
    inc @time_ptr
    bne @d
    inc @time_ptr + 1

    ; day
@d: lda (@time_ptr)
    sta RTC + DS1501_DATE
    inc @time_ptr
    bne @h
    inc @time_ptr + 1

    ; hour
@h: lda (@time_ptr)
    sta RTC + DS1501_HOUR
    inc @time_ptr
    bne @i
    inc @time_ptr + 1

    ; minute
@i: lda (@time_ptr)
    sta RTC + DS1501_MINUTE
    inc @time_ptr
    bne @s
    inc @time_ptr + 1

    ; second
@s: lda (@time_ptr)
    sta RTC + DS1501_SECOND
    inc @time_ptr
    bne @w
    inc @time_ptr + 1

    ; day of week
@w: lda (@time_ptr)
    sta RTC + DS1501_DAY
    inc @time_ptr
    bne @exit
    inc @time_ptr + 1

    ; Restore control b register (we modified it above to turn off clock 
    ; updates).
@exit:
    pla
    ora #DS1501_CTL_B_TE_ON
    sta RTC + DS1501_CONTROL_B

    set_acc_16

    pull_reg r0
    plp
    pla
	rts
