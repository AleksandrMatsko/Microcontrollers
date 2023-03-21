;
; AssemblerApplication1.asm
;
; Created: 07.02.2023 14:31:21
; Author : AMats
;

.include "m168def.inc"

.DSEG
.CSEG

.org $000 rjmp start

; Replace with your application code
start:

MAIN:
	ldi		r16, 1	; == a
	ldi		r17, 2		; == b
	ldi		r18, 3		; == d
	sub		r16, r17	; r16 == a - b
	muls	r16, r18	; r16 = (a - b) * d
	brpl	non_negative
	ldi		r20, 1
non_negative:
	ldi		r21, 1
	rjmp MAIN
	
