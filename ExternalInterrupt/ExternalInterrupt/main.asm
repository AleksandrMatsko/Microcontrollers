;
; ExternalInterrupt.asm
;
; Created: 21.02.2023 14:25:37
; Author : AMats
;

.include "m168def.inc"
	
.equ	INTR = -1

.DSEG


.CSEG

.org 0x0000		rjmp start
.org 0x0002		rjmp INT0_handler
.org 0x0020		rjmp TC0_overflow_handler

INT0_handler:
	in		r16, sreg
	push	r16
	
	inc		r20
	
	pop		r16
	out		sreg, r16
	reti

TC0_overflow_handler:
	in		r16, sreg
	push	r16
	
	inc		r21
	
	pop		r16
	out		sreg, r16
	reti


start:
	cli
	ldi		r16, low(RAMEND)
	out		SPL, r16
	ldi		r16, high(RAMEND)
	out		SPH, r16
; prepare for external interrupts
	ldi		r16, 1
	ldi		r30, low(EICRA)
	ldi		r31, high(EICRA)
	st		Z, r16
	out		EIMSK, r16
; prepare for timer/counter interrupts
	out		TCCR0B, r16
	ldi		r30, low(TIMSK0)
	ldi		r31, high(TIMSK0)
	st		Z, r16
	sei

cycle:
	ldi		r16, 2
	jmp		cycle
					


