;
; WorkingWithUART.asm
;
; Created: 14.03.2023 14:32:00
; Author : AMats
;

.include "m168def.inc"
	
.equ	STOP_VAL = 2

.DSEG

to_trans:	.BYTE	2
counter:	.BYTE	1

.CSEG

.org 0x0000		jmp start
.org 0x0024		jmp RCV_complete_interrupt
.org 0x0026		jmp Data_empty_interrupt
.org 0x0028		jmp TRNS_complete_interrupt

RCV_complete_interrupt:
	in		r16, SREG
	push	r16

	ldi		r30, low(UDR0)
	ldi		r31, high(UDR0)
	ld		r16, Z

	ldi		r30, low(to_trans)
	ldi		r31, high(to_trans)
	st		Z+, r16
	st		Z, r16

	ldi		r16, 0
	ldi		r30, low(counter)
	ldi		r31, high(counter)
	st		Z, r16

	cli

	ldi		r16, (1 << TXCIE0) | (1 << TXEN0) | (1 << UDRIE0) ; enable transmiter, transmitter and data empty interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	;ld		r17, Z
	;or		r16, r17	; turned off receiver and receive interrupt
	st		Z, r16

	pop		r16
	out		SREG, r16
	reti

Data_empty_interrupt:
	in		r16, SREG
	push	r16

	ldi		r17, 0

	ldi		r30, low(counter)
	ldi		r31, high(counter)
	ld		r16, Z
	cpi		r16, STOP_VAL
	breq	stop  ; check counter

	ldi		r28, low(to_trans)
	ldi		r29, high(to_trans)
	add		r28, r16
	adc		r29, r17
	ld		r18, Y ; get val from memory on position [counter]

	ldi		r28, low(UDR0)
	ldi		r29, high(UDR0)
	st		Y, r18	; put the val into data register to send

	inc		r16
	st		Z, r16 ; increment counter and save it

stop:
	pop		r16
	out		SREG, r16
	reti

TRNS_complete_interrupt:
	in		r16, SREG
	push	r16

	nop

	pop		r16
	out		SREG, r16
	reti


start:
    cli		
	ldi		r16, low(RAMEND)
	out		SPL, r16
	ldi		r16, high(RAMEND)
	out		SPH, r16

	ldi		r16, 0
	ldi		r30, low(UCSR0A)
	ldi		r31, high(UCSR0A)
	st		Z, r16	; clear all flags

	ldi		r16, (0 << UMSEL01) | (0 << UMSEL00) | (1 << UPM01) | (0 << UPM00) | (0 << USBS0) | (1 << UCSZ01) | (1 << UCSZ00) ; choose async mode, even parity, one stop bit, 8-bit of data
	ldi		r30, low(UCSR0C)
	ldi		r31, high(UCSR0C)
	st		Z, r16  ; set configuration

	ldi		r16, 103
	ldi		r30, low(UBRR0L)
	ldi		r31, high(UBRR0L)
	st		Z, r16

	ldi		r16, (1 << RXCIE0) | (1 << RXEN0) ; enable receiver and receive interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r16

	sei

loop:
	nop
	rjmp	loop

