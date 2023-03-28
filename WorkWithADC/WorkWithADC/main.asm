;
; WorkWithADC.asm
;
; Created: 28.03.2023 14:36:43
; Author : AMats
;

.include "m168def.inc"
	
.equ	STOP_VAL = 2

.DSEG

to_trans:	.BYTE	2
counter:	.BYTE	1

.CSEG

.org 0x0000		jmp start
.org 0x002A		rjmp ADC_complete

ADC_complete:
	in		r16, SREG
	push	r16

	ldi		r30, low(ADCL)
	ldi		r31, high(ADCL)
	ld		r18, Z	; get low 8 bits
	ldi		r30, low(ADCH)
	ldi		r31, high(ADCH)
	ld		r19, Z	; get high 2 bits

	ldi		r30, low(ADCSRA)
	ldi		r31, high(ADCSRA)
	ld		r17, Z
	ori		r17, (1 << ADSC)
	st		Z, r17 ; start conversion

	pop		r16
	out		SREG, r16
	reti


start:
    cli		
	ldi		r16, low(RAMEND)
	out		SPL, r16
	ldi		r16, high(RAMEND)
	out		SPH, r16

	ldi		r16, 0	; using AREF, ADLAR = 0, ADC0
	ldi		r30, low(ADMUX)
	ldi		r31, high(ADMUX)
	st		Z, r16

	ldi		r16, (1 << ADEN) | (1 << ADIE) ; enable ADC, enable ADC interrupt
	ldi		r30, low(ADCSRA)
	ldi		r31, high(ADCSRA)
	st		Z, r16

	ldi		r16, (1 << ADC0D) ; digital input disable for ADC0
	ldi		r30, low(DIDR0)
	ldi		r31, high(DIDR0)
	st		Z, r16 ; 

	sei

	ldi		r30, low(ADCSRA)
	ldi		r31, high(ADCSRA)
	ld		r17, Z
	ori		r17, (1 << ADSC)
	st		Z, r17 ; start conversion

loop:
	nop
	rjmp	loop
