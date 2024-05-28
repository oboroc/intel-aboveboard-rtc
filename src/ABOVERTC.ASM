;
; AboveRTC version 0.01
; Copyright (c) 1985 Intel Corporation
;
; Get or set time in Real-time clock chip of Intel Above Board ISA
; multifunction card
;
; This program is derivative work from disassembly of the original
; Intel clock.sys driver
;
; Created by Adrian Oboroc
;
; To build, use MASM 5.1:
;   masm.exe /V /Z /ZI abovertc,,,;
;   link.exe abovertc;
;
; TODO: undecided on coding style, need to find something good to
; follow/emulate
;

.model small
.stack
.data
banner	db	"Detecting Intel Above Board RTC",13,10,"$"
found	db	"Found!",13,10,"$"
nfound	db	"Not found.",13,10,"$"

time_s	db	"00:00:00",13,10,"$"

second	db	0	; 0 to 59
minute	db	0	; 0 to 59
hour	db	0	; 0 to 23
day	db	0	; 1 to 31
month	db	0	; 1 to 12
year	db	0

ten	db	10

NIBBLE		equ	0Fh	; 4 lower bits in a byte

RTC_SEC1	equ	2C0h
RTC_SEC10	equ	2C1h
RTC_MIN1	equ	2C2h
RTC_MIN10	equ	2C3h
RTC_HOUR1	equ	2C4h
RTC_HOUR10	equ	2C5h
RTC_DAY1	equ	2C6h
RTC_DAY10	equ	2C7h
RTC_MONTH1	equ	2C8h
RTC_MONTH10	equ	2C9h
RTC_YEAR1	equ	2CAh
RTC_YEAR10	equ	2CBh
RTC_WEEKDAY	equ	2CCh
RTC_CONTROL	EQU	2CDh

print	MACRO	msg
	mov	ax,SEG msg
	mov	ds,ax
	mov	dx,OFFSET msg
	mov	ah,09h
	int	21h
	ENDM

; quit to dos macro
; takes optional argument - return error code (0-255)
quit	MACRO	errcode
	IFNB	<errcode>	; if macro was passed an argument
	mov	ah,4ch
	mov	al,errcode
	ELSE
	mov	ax,4c00h
	ENDIF
	int	21h
	ENDM

.code
_start:
	print	banner

	xor	bl,bl

loop1:
	call	rtc_init

        ; I/O delay
	nop
	nop
	nop

	in	al,dx
	or	al,1
	out	dx,al
        inc	bl
	mov	cx,100

loop2:	in	al,dx
	test	al,2
	jz	rtc_found
	loop	loop2

	cmp	bl,2
	jnz	loop1

	print	nfound
	quit	100

rtc_found:
	print	found

; >>> put something here <<<

;	call	rtc_get_time

	mov	dl,7
	add	dl,48
	mov	ah,02h
	int	21h




	;rtc_get_date

	quit


rtc_init	proc	near
	mov	dx,RTC_CONTROL
	in	al,dx
	and	al,0Eh
	out	dx,al
	ret
rtc_init	endp


rtc_get_time	proc	near
	mov	dx,RTC_SEC1
	in	al,dx
	and	al,NIBBLE
	cmp	al,9
	jbe	sec1
	jmp	bad_time
; set lower digit of second, for example for 47 seconds it will be 7
sec1:	mov	[second],al

; my own mess - stuff digits into string time_s
	add	al,48	; convert digit to ascii character for that digit
	mov	bx,OFFSET time_s + 8
	mov	byte ptr [bx],al

	mov	dx,RTC_SEC10
	in	al,dx
	and	al,NIBBLE
	cmp	al,5
	jbe	sec10
	jmp	bad_time
; set higher digit of second, for example for 47 seconds, al is 4
sec10:	mul	byte ptr [ten]
	add	byte ptr [second],al
; now al is seconds from 0 to 59

	mov	dx,RTC_MIN1
	in	al,dx
	and	al,NIBBLE
	cmp	al,9
	jbe	min1
	jmp	bad_time
min1:	mov	[minute],al

	mov	dx,RTC_MIN10
	in	al,dx
	and	al,NIBBLE
	cmp	al,5
	jbe	min10
	jmp	bad_time
min10:	mul	byte ptr [ten]
	add	byte ptr [minute],al
; now al is minutes from 0 to 59

	mov	dx,RTC_HOUR1
	in	al,dx
	and	al,NIBBLE
	cmp	al,9
	jbe	hour1
	jmp	bad_time
hour1:	mov	[hour],al

	mov	dx,RTC_HOUR10
	in	al,dx
	and	al,NIBBLE
	cmp	al,2
	jbe	hour10
	jmp	bad_time
hour10:	mul	byte ptr [ten]
	add	byte ptr [hour],al
	mov	ah,byte ptr [hour]
	cmp	ah,23
	ja	bad_time
; now al is hour from 0 to 23

	call	rtc_init
;	les	bx,dword ptr [request]
;	mov	word ptr es:[bx + 03h],0100h	; request header +03h - status
	ret

bad_time:
	call	rtc_init
;	les	bx,dword ptr [request]
;	mov	word ptr es:[bx + 03h],810Ch	; request header +03h - status
	xor	ax,ax
	mov	[second],al
	mov	[minute],al
	mov	[hour],al
	ret
rtc_get_time	endp


end	_start
