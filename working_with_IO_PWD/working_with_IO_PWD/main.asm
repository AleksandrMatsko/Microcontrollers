;
; working_with_IO_PWD.asm
;
; Created: 28.02.2023 14:24:41
; Author : AMats
;

.include "m168def.inc"
	
.equ	INTR = -1
.equ	HIGH_LEVEL_FREQ = 127

.DSEG

.CSEG

.org 0x0000		rjmp start
.org 0x001E		rjmp TC0_cmp_handler
.org 0x0020		rjmp TC0_overflow_handler


TC0_overflow_handler:
	in		r16, SREG
	push	r16
	
	inc		r21
	
	pop		r16
	out		SREG, r16
	reti

TC0_cmp_handler:
	in		r16, SREG
	push	r16
	
	inc		r20
	
	pop		r16
	out		SREG, r16
	reti

start:
	cli
	ldi		r16, low(RAMEND)
	out		SPL, r16
	ldi		r16, high(RAMEND)
	out		SPH, r16

; turn on output
	ldi		r16, (1 << DDD5)
	out		DDRD, r16
	ldi		r16, (1 << PIND5)
	out		PIND, r16
	ldi		r16, (1 << PORTD5)
	out		PORTD, r16

; setting value to compare
	ldi		r16, HIGH_LEVEL_FREQ
	sts		0x48, r16 ; OCR0B

; prepare for timer/counter interrupts
; set OC0B on compare match, clear OC0B at BOTTOM, (non-inverting mode)
	ldi		r16, (0 << WGM02) | (1 << CS00)
	out		TCCR0B, r16
	ldi		r16, (1 << COM0B1) | (1 << COM0B0) | (1 << WGM01) | (1 << WGM00)
	out		TCCR0A, r16

	ldi		r16, (1 << OCIE0B) | (1 << TOIE0)
	ldi		r30, low(TIMSK0)
	ldi		r31, high(TIMSK0)
	st		Z, r16

	sei


cycle:
	ldi		r17, 2
	jmp		cycle
