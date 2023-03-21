;
; LikeInTest.asm
;
; Created: 14.03.2023 13:09:35
; Author : AMats
;

.equ	a = 1
.equ	b = 2
.equ	c = 3

.org 0x0000		rjmp	start

; Replace with your application code
start:
    ldi		r16, a
	cpi		r16, b
	brne	compare_with_c
	nop
	jmp		end

compare_with_c:
	nop

end:
	nop
