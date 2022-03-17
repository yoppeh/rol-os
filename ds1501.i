;
; ds1501.i
;
; Declarations for the ds1501 real time clock chip.
;

.ifndef _ROL_DS1501_I
_ROL_DS1501_I = 1


; Battery condition values
DS1501_VBAT_MASK = $0002
DS1501_VBAT_LOW = $0000
DS1501_VBAT_OK = $0002
DS1501_VBAUX_MASK = $0001
DS1501_VBAUX_LOW = $0000
DS1501_VBAUX_OK = $0001

; RTC register offsets
DS1501_SECOND = $0000
DS1501_MINUTE = $0001
DS1501_HOUR = $0002
DS1501_DAY = $0003
DS1501_DATE = $0004
DS1501_MONTH = $0005
DS1501_YEAR = $0006
DS1501_CENTURY = $0007
DS1501_ALARM_SECOND = $0008
DS1501_ALARM_MINUTE = $0009
DS1501_ALARM_HOUR = $000a
DS1501_ALARM_DAY_DATE = $000b
DS1501_WATCHDOG_MILLISECOND = $000c
DS1501_WATCHDOG_SECOND = $000d
DS1501_CONTROL_A = $000e
DS1501_CONTROL_B = $000f
DS1501_RAM_ADDRESS = $0010
DS1501_RAM_DATA = $0013

; Control Register B flags
DS1501_CTL_B_TE_ON = %10000000      ; transfer enable
DS1501_CTL_B_TE_OFF = %00000000     ; transfer disable
DS1501_CTL_B_TE_MASK = %01111111    ; te bit mask
DS1501_CTL_B_CS_ON = %01000000      ; crystal select = 12.5pF
DS1501_CTL_B_CS_OFF = %00000000     ; crystal select = 6pF
DS1501_CTL_B_CS_MASK = %10111111    ; cs bit mask
DS1501_CTL_B_BME_ON = %00100000     ; burst-mode enable
DS1501_CTL_B_BME_OFF = %00000000    ; burst-mode disable
DS1501_CTL_B_BME_MAS = %11011111    ; bme bit mask
DS1501_CTL_B_TPE_ON = %00010000     ; time-of-day/date alarm power enable
DS1501_CTL_B_TPE_OFF = %00000000    ; time-of-day/date alarm power disable
DS1501_CTL_B_TPE_MASK = %11101111   ; tpe bit mask
DS1501_CTL_B_TIE_ON = %00001000     ; time-of-day/date alarm interrupt enable
DS1501_CTL_B_TIE_OFF = %00000000    ; time-of-day/date alarm interrupt disable
DS1501_CTL_B_TIE_MASK = %11110111   ; tie bit mask
DS1501_CTL_B_KIE_ON = %00000100     ; kickstart enable interrupt
DS1501_CTL_B_KIE_OFF = %00000000    ; kickstart disable interrupt
DS1501_CTL_B_KIE_MASK = %11111011   ; kie bit mask
DS1501_CTL_B_WDE_ON = %00000010     ; watchdog enable
DS1501_CTL_B_WDE_OFF = %00000000    ; watchdog disable
DS1501_CTL_B_WDE_MASK = %11111101   ; watchdog bit mask
DS1501_CTL_B_WDS_ON = %00000001     ; watchdog steering on
DS1501_CTL_B_WDS_OFF = %00000000    ; watchdog steering off
DS1501_CTL_B_WDS_MASK = %11111110   ; watchdog steering bit mask


; The global RTC device.
.global RTC


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

.global ds1501_init

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

.global ds1501_read_batteries

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

.global ds1501_read_date

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

.global ds1501_set_date


.endif ; _ROL_DS1501_I