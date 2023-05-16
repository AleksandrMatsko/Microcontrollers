;
; FlashingDiode.asm
;
; Created: 11.04.2023 14:43:11
; Author : AMats
;


; Replace with your application code
.include "m168def.inc"
	
.equ	INTR = -1
.equ	HIGH_LEVEL_FREQ = 127

.equ	HIGH_STOP = 0b01111010
.equ	LOW_STOP = 0b00010010	; encoded 31250

.DSEG

.CSEG

.org 0x0000		rjmp start
;.org 0x001E		rjmp TC0_cmp_handler
.org 0x0020		rjmp TC0_overflow_handler


TC0_overflow_handler:
	in		r16, SREG
	push	r16
	
	add		r22, r18
	adc		r23, r17

	cpi		r23, HIGH_STOP
	brne	stop

	cpi		r22, LOW_STOP
	brne	stop

	in		r16, PORTD
	eor		r16, r19	; xor (1 << PORTD5)
	out		PORTD, r16

	ldi		r22, 0
	ldi		r23, 0
	out		TCNT0, r22

stop:	
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
	ldi		r19, (1 << PIND5)
	out		PIND, r19
	ldi		r19, (1 << PORTD5)
	out		PORTD, r19

; setting value to compare
;	ldi		r16, HIGH_LEVEL_FREQ
;	sts		0x48, r16 ; OCR0B

; prepare for timer/counter interrupts
; normal mode
	ldi		r16, (0 << WGM02) | (0 << CS02) | (0 << CS01) | (1 << CS00) ; clk / 1
	out		TCCR0B, r16
	ldi		r16, (0 << COM0B1) | (0 << COM0B0) | (0 << WGM01) | (0 << WGM00)
	out		TCCR0A, r16

	ldi		r16, (1 << TOIE0) ; | (1 << OCIE0B)
	ldi		r30, low(TIMSK0)
	ldi		r31, high(TIMSK0)
	st		Z, r16

	sei

	ldi		r18, 1
	ldi		r17, 0


cycle:
	nop
	jmp		cycle
