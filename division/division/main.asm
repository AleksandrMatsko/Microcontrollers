;
; division.asm
;
; Created: 07.03.2023 14:51:37
; Author : AMats
;

.include "m168def.inc"

.def	remainder = r16
.def	dividend = r17 ; passed to div8u
.def	divisor = r18 ; passed to div8u
.def	counter = r19

.equ	INTR = -1

.DSEG


.CSEG

.org 0x0000		rjmp start



div8u:
	in		r1, sreg
	push	r1
	push	counter
	
	sub		remainder, remainder ; clear remainder
	ldi		counter, 9 ; init loop counter

div8u_shift_1:
	rol		dividend ; shift dividend left with carry
	dec		counter
	brne	div8u_shift_2 ; if counter != 0 jmp to label
	rjmp	div8u_restore ; counter == 0, so finished division

div8u_shift_2:
	rol		remainder ; shift remainder left with carry
	sub		remainder, divisor
	brcc	div8u_res_not_negative ; if remainder - divisor > 0 jmp to label
	add		remainder, divisor ; restore remainder
	clc		; clear carry flag
	rjmp	div8u_shift_1

div8u_res_not_negative:
	sec		; set carry flag
	rjmp	div8u_shift_1


div8u_restore:
	pop		counter
	pop		r1
	out		sreg, r1
	ret


start:
	cli
	ldi		r16, low(RAMEND)
	out		SPL, r16
	ldi		r16, high(RAMEND)
	out		SPH, r16
	sei

	ldi		dividend, 16
	ldi		divisor, 4
	call	div8u
	nop


