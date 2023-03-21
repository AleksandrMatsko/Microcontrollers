;
; AssemblerApplication1.asm
;
; Created: 07.02.2023 15:44:02
; Author : AMats
;


.include "m168def.inc"

.DSEG
.CSEG

.org $000 rjmp start

; Replace with your application code
start:

MAIN:
	ldi		r16, 1		; shift
	ldi		r17, 0		; counter
	ldi		r18, 7
	ldi		r19, 0
	jmp		goleft

goleft:
	inc		r17
	lsl		r16
	cp		r17, r18
	breq	goright
	jmp		goleft

goright:
	dec		r17
	lsr		r16
	cp		r17, r19
	breq	goleft
	jmp		goright
	

