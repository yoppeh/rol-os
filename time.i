;
; time.i
;
; Date/time routines.
;

.ifndef _ROL_TIME_I
_ROL_TIME_I = 1


; Structure used to represent a date/time.
.struct TIME_BCD_T
    century .byte
    year    .byte
    month   .byte
    day     .byte
    hour    .byte
    minute  .byte
    second  .byte
    dow     .byte
.endstruct


;
; time_format_date
;
;   Takes an 8 byte BCD formatted date (as returned by date_read_date), a 
;   format string and an output buffer and generates a human-readable 
;   date/time string.
;
; Input:
;
;   r0 
;       lower 16 bits = pointer to TIME_BCD_T struct.
;       upper 16 bits = pointer to format string. This uses a subset of the 
;           format specifiers found in the unix strftime function:
;           %A = full weekday name
;           %a = abbreviated weekday
;           %B = full month name
;           %b = abbreviated month name
;           %C = year / 100 (century), zero-padded from the left
;           %d = day of the month as a decimal number (01 - 31)
;           %e = day of the month as a decimal number (1 - 31)
;           %H = 24-hour hour as a decimal number (00 - 23)
;           %I = 12-hour hour as a decimal number (01 - 12)
;           %j = day of the year as a decimal number (001 - 366)
;           %k = 24-hour hour as a decimal number (0 - 23) blank-pad from left
;           %l = 12-hour hour as a decimal number (1 - 12) blank-pad from left
;           %M = minute as a decimal number (00 - 59)
;           %m = month as a decimal number (01 - 12)
;           %n = newline
;           %P = AM or PM
;           %p = am or pm
;           %S = second as a decimal number (00 - 60)
;           %t = tab
;           %u = weekday (monday is the first day) as a decimal # (1 - 7)
;           %Y = year with century as a decimal #
;           %y = year without century as a decimal # (00 - 99)
;           %% = %            
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

.global time_format_date


.endif ; _ROL_TIME_I