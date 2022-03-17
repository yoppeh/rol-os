;
; time.s
;
; Date/time routines.
;

.include "rol.i"
.include "w65c22.i"

.include "ascii.i"
.include "bcd.i"
.include "ds1501.i"
.include "time.i"


.code


;
; bcd_to_ascii
;
;   Private Subroutine.
;
;   Converts a two-digit BCD number to the equivalent two ASCII characters. So,
;   0x19 gets written to the output buffer pointed to by r1 as "19". The 
;   pointer in r1 is incremented to point to the character after the last
;   character placed in the buffer.
;
;   The routine takes a second parameter in r0 + 1, which indicates whether to
;   left-pad the result with '0'. So, if the r0 + 1 flag is 1, then 0x09 gets
;   output as "09". If r0 + 1 is 0, then the output would be "9".
;
; Input:
;
;   r0
;       lower byte = 2 digit BCD formatted number.
;       next byte = zero-left-pad flag, 0 = no pad, 1 = left-pad with '0'.
;   r1
;       lower 16 bites = pointer to output buffer into which the ASCII 
;       characters are placed.
;
; Output:
;
;   accumulator altered.
;   flags altered.
;
;   r1
;       lower 16 bits = Points to the location in the output buffer 1 character
;           past the last character written.
;

bcd_to_ascii:

@bcd = r0
@zero_fill = r0 + 1
@output_ptr = r1

    set_acc_8
    lda @bcd
    ror
    ror
    ror
    ror
    and #$0f
    bne @s
    cmp @zero_fill
    beq @n
@s: ora #$30
    sta (@output_ptr)
    set_acc_16
    inc @output_ptr
    set_acc_8
@n: lda @bcd
    and #$0f
    ora #$30
    sta (@output_ptr)
    set_acc_16
    inc @output_ptr
    rts


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

time_format_date:

@time_ptr = r0 
@format_ptr = r0 + 2
@output_ptr = r1

    pha
    phx
    push_reg r0
    push_reg r1

    ; Get next character from format string.
@next:
    set_acc_8

    lda (@format_ptr)
    beq @exit
    cmp #'%'
    bne @store_char

    set_all_16
    inc @format_ptr
    set_acc_8

    ; Another % here means to use a literal '%' as the next character.
    lda (@format_ptr)
    beq @exit
    cmp #'%'
    beq @store_char

    ; n is a newline
    cmp #'n'
    bne @check_tab
    lda #ASCII_LF
    bra @store_char

    ; t is a tab
@check_tab:
    cmp #'t'
    bne @lookup_format
    lda #ASCII_TAB
    bra @store_char

@lookup_format:
    ldx #0
@n: cmp fmt_handler_tbl, x
    bne @calc_next
    set_acc_16
    jsr (fmt_handler_tbl + 1, x)
    inc @format_ptr
    bra @next

@calc_next:
    .a8
    lda #$00
    cmp fmt_handler_tbl, x
    bne @next_char
    set_acc_16
    inc @format_ptr
    bra @next

@next_char:
    .a8
    lda (@format_ptr)
    inx
    inx
    inx
    bra @n

@store_char:
    sta (@output_ptr)
    set_acc_16
    inc @format_ptr
    inc @output_ptr
    bra @next

    ; All done
@exit:
    set_acc_8
    lda #0
    sta (@output_ptr)
    set_acc_16

    pull_reg r1
    pull_reg r0
    plx
    pla
    rts


;
; format_A
;
;   Given: 2022-03-13 13:27:00 1
;   Places "Sunday" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to TIME_BCD_T date/time.
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;   r1 will point to the first character past the end of the string copied
;       into the output buffer.
;

format_A:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ldy #TIME_BCD_T::dow
    lda #0
    set_acc_8
    lda (@time_ptr), y
    cmp #1
    bcc @z
    cmp #8
    bcc @d
    lda #7
@d: dec a
    asl a
@z: tay
    lda days_of_week_table, y
    sta @time_ptr
    lda days_of_week_table + 1, y
    sta @time_ptr + 1

@n: set_acc_8
    lda (@time_ptr)
    beq @exit
    sta (@output_ptr)
    set_acc_16
    inc @time_ptr
    inc @output_ptr
    bra @n

@exit:
    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_a
;
;   Given: 2022-03-13 13:27:00 1
;   Places "Sun" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_a:

@time_ptr = r0
@output_ptr = r1

    pha
    phx
    phy
    push_reg r0

    ldy #TIME_BCD_T::dow
    lda #0
    ldx #3
    set_acc_8
    lda (@time_ptr), y
    cmp #1
    bcc @z
    cmp #8
    bcc @d
    lda #8
@d: dec
    clc
    rol
@z: tay
    lda days_of_week_table, y
    sta @time_ptr
    lda days_of_week_table + 1, y
    sta @time_ptr + 1

@n: set_acc_8
    lda (@time_ptr)
    beq @exit
    sta (@output_ptr)
    set_acc_16
    inc @time_ptr
    inc @output_ptr
    dex
    bne @n

@exit:
    set_all_16
    pull_reg r0
    ply
    plx
    pla
    rts


;
; format_B
;
;   Given: 2022-03-13 13:27:00 1
;   Places "March" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_B:

@time_ptr = r0
@tmp1 = r0
@tmp2 = r0 + 2
@output_ptr = r1

    pha
    phy
    push_reg r0

    ldy #TIME_BCD_T::month
    lda (@time_ptr), y
    and #$00ff
    sta r0
    jsr bcd_bcd8_to_u8
    lda r0
    beq @exit
    cmp #13
    bcs @exit
    dec a
    asl a

@z: tay
    lda month_name_table, y
    sta @time_ptr

@n: set_acc_8
    lda (@time_ptr)
    beq @exit
    sta (@output_ptr)
    set_acc_16
    inc @time_ptr
    inc @output_ptr
    bra @n

@exit:
    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_b
;
;   Given: 2022-03-13 13:27:00 1
;   Places "Mar" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_b:

@time_ptr = r0
@tmp1 = r0
@tmp2 = r0 + 2
@output_ptr = r1

    pha
    phx
    phy
    push_reg r0

    ldy #TIME_BCD_T::month
    lda (@time_ptr), y
    and #$00ff
    sta r0
    jsr bcd_bcd8_to_u8
    lda r0
    beq @exit
    cmp #13
    bcs @exit
    dec a
    asl a

@z: tay
    lda month_name_table, y
    sta @time_ptr
    ldx #3

@n: set_acc_8
    lda (@time_ptr)
    beq @exit
    sta (@output_ptr)
    set_acc_16
    inc @time_ptr
    inc @output_ptr
    dex
    bne @n

@exit:
    set_acc_16
    pull_reg r0
    ply
    plx
    pla
    rts


;
; format_C
;
;   Given: 2022-03-13 13:27:00 1
;   Places "20" in the output buffer.
;
;   Given: 122-03-13 13:27:00 2
;   Places "01" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_C:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the century value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::century
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_d
;
;   Given: 2022-03-08 13:27:00 1
;   Places "08" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_d:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the day of month value from the TIME_BCD_T structure and save it to 
    ; r0.
    set_acc_8
    ldy #TIME_BCD_T::day
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_e
;
;   Given: 2022-03-08 13:27:00 1
;   Places "8" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_e:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the day of month value from the TIME_BCD_T structure and save it to
    ; r0.
    set_acc_8
    ldy #TIME_BCD_T::day
    lda (@time_ptr), y
    sta r0
    lda #0
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_H
;
;   Given: 2022-03-08 13:27:00 1
;   Places "13" in the output buffer.
;
;   Given: 2022-03-08 01:27:00 1
;   Places "01" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_H:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the hour value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::hour
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_I
;
;   Given: 2022-03-08 13:27:00 1
;   Places "01" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_I:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the hour value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::hour
    lda (@time_ptr), y
    sta r0

    ; Need to conver the 24-hour format hour to 12-hour format. If 24-hour
    ; value is 0, then set it to 12.
    sed
    cmp #$01
    bcs @t
    lda #$12
    sta r0
    bra @n

    ; If the 24-hour format hour is later than 12, need to subtract 12 from it.
@t: cmp #$13
    bcc @n
    sec
    sbc #$12
    sta r0

    ; Shift the 10's digit into the low nybble, add '0' to get ASCII value.
@n: cld
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_j
;
;   Places a date/time component string in the output buffer. Where string is 
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_j:

    rts


;
; format_k
;
;   Given: 2022-03-08 01:27:00 1
;   Places "1" in the output buffer.
;
;   Given: 2022-03-08 13:27:00 1
;   Places "13" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_k:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the hour value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::hour
    lda (@time_ptr), y
    sta r0
    lda #0
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_l
;
;   Given: 2022-03-08 13:27:00 1
;   Places "1" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_l:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the hour value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::hour
    lda (@time_ptr), y
    sta r0

    ; Need to conver the 24-hour format hour to 12-hour format. If 24-hour
    ; value is 0, then set it to 12.
    sed
    cmp #$01
    bcs @t
    lda #$12
    sta r0
    bra @n

    ; If the 24-hour format hour is later than 12, need to subtract 12 from it.
@t: cmp #$13
    bcc @n
    sec
    sbc #$12
    sta r0

    ; Shift the 10's digit into the low nybble, add '0' to get ASCII value.
@n: cld
    lda #0
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_M
;
;   Given: 2022-03-08 13:07:00 1
;   Places "07" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_M:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the hour value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::minute
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts

;
; format_m
;
;   Given: 2022-03-08 13:07:00 1
;   Places "03" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_m:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the month value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::month
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts

;
; format_P
;
;   Given: 2022-03-08 01:07:00 1
;   Places "AM" in the output buffer.
;
;   Given: 2022-03-08 13:07:00 1
;   Places "PM" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_P:

@time_ptr = r0
@output_ptr = r1

    pha

    lda #$4d50      ; 'PM'
    sta (@output_ptr)

    ldy #TIME_BCD_T::hour
    lda (@time_ptr), y
    and #$00ff
    cmp #$13
    bcs @p

    lda #$4d41      ; 'AM'
    sta (@output_ptr)

@p: inc @output_ptr
    inc @output_ptr
    pla
    rts

;
; format_p
;
;   Given: 2022-03-08 01:07:00 1
;   Places "am" in the output buffer.
;
;   Given: 2022-03-08 13:07:00 1
;   Places "pm" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_p:

@time_ptr = r0
@output_ptr = r1

    pha

    lda #$6d70      ; 'PM'
    sta (@output_ptr)

    ldy #TIME_BCD_T::hour
    lda (@time_ptr), y
    and #$00ff
    cmp #$13
    bcs @p

    lda #$6d61      ; 'AM'
    sta (@output_ptr)

@p: inc @output_ptr
    inc @output_ptr
    pla
    rts


;
; format_S
;
;   Given: 2022-03-08 01:07:00 1
;   Places "00" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_S:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the second value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::second
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_u
;
;   Given: 2022-03-08 23:07:00 1
;   Places "1" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_u:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
 
    set_acc_8
    ldy #TIME_BCD_T::dow
    lda (@time_ptr), y
    ora #$30
    sta (@output_ptr)
    set_acc_16
    inc @output_ptr

    ply
    pla
    rts


;
; format_Y
;
;   Given: 2022-03-08 13:07:00 1
;   Places "2022" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_Y:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the year value from the TIME_BCD_T structure and save it to the 
    ; stack.
    set_acc_8
    ldy #TIME_BCD_T::year
    lda (@time_ptr), y
    pha

    ; Get the century value from the TIME_BCD_T structure and save it to
    ; r0.
    ldy #TIME_BCD_T::century
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii
    set_acc_8

    ; Get the year value from the TIME_BCD_T structure and save it to r0.
    pla
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts


;
; format_y
;
;   Given: 2022-03-08 13:07:00 1
;   Places "22" in the output buffer.
;
; Input:
;
;   r0
;       lower 16 bits = pointer to 7 byte BCD date/time (date_date format).
;   r1
;       lower 16 bits = pointer to output buffer.
;
; Output:
;
;   flags altered.
;

format_y:

@time_ptr = r0
@output_ptr = r1

    pha
    phy
    push_reg r0

    ; Get the year value from the TIME_BCD_T structure and save it to r0.
    set_acc_8
    ldy #TIME_BCD_T::year
    lda (@time_ptr), y
    sta r0
    lda #1
    sta r0 + 1
    jsr bcd_to_ascii

    set_acc_16
    pull_reg r0
    ply
    pla
    rts

 
.rodata

dow_sunday_str:
    .byte "Sunday", 0
dow_monday_str:
    .byte "Monday", 0
dow_tuesday_str:
    .byte "Tuesday", 0
dow_wednesday_str:
    .byte "Wednesday", 0
dow_thursday_str:
    .byte "Thursday", 0
dow_friday_str:
    .byte "Friday", 0
dow_saturday_str:
    .byte "Saturday", 0

days_of_week_table:
    .addr dow_sunday_str
    .addr dow_monday_str
    .addr dow_tuesday_str
    .addr dow_wednesday_str
    .addr dow_thursday_str
    .addr dow_friday_str
    .addr dow_saturday_str

month_name_jan_str:
    .byte "January", 0
month_name_feb_str:
    .byte "February", 0
month_name_mar_str:
    .byte "March", 0
month_name_apr_str:
    .byte "April", 0
month_name_may_str:
    .byte "May", 0
month_name_jun_str:
    .byte "June", 0
month_name_jul_str:
    .byte "July", 0
month_name_aug_str:
    .byte "August", 0
month_name_sep_str:
    .byte "September", 0
month_name_oct_str:
    .byte "October", 0
month_name_nov_str:
    .byte "November", 0
month_name_dec_str:
    .byte "December", 0

month_name_table:
    .addr month_name_jan_str
    .addr month_name_feb_str
    .addr month_name_mar_str
    .addr month_name_apr_str
    .addr month_name_may_str
    .addr month_name_jun_str
    .addr month_name_jul_str
    .addr month_name_aug_str
    .addr month_name_sep_str
    .addr month_name_oct_str
    .addr month_name_nov_str
    .addr month_name_dec_str

fmt_handler_tbl:
    .byte 'A'
    .addr format_A
    .byte 'a'
    .addr format_a
    .byte 'B'
    .addr format_B
    .byte 'b'
    .addr format_b
    .byte 'C'
    .addr format_C
    .byte 'd'
    .addr format_d
    .byte 'e'
    .addr format_e
    .byte 'H'
    .addr format_H
    .byte 'I'
    .addr format_I
    .byte 'j'
    .addr format_j
    .byte 'k'
    .addr format_k
    .byte 'l'
    .addr format_l
    .byte 'M'
    .addr format_M
    .byte 'm'
    .addr format_m
    .byte 'P'
    .addr format_P
    .byte 'p'
    .addr format_p
    .byte 'S'
    .addr format_S
    .byte 'u'
    .addr format_u
    .byte 'Y'
    .addr format_Y
    .byte 'y'
    .addr format_y
    .byte $00
    .addr $0000
