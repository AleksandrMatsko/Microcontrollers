;
; SendWithUSART.asm
;
; Created: 28.03.2023 12:16:59
; Author : AMats
;


; Replace with your application code
.equ	STOP_VAL = 2
.equ	MESSAGE = 0b10011001

.DSEG

.CSEG

.org 0x0000		jmp start
.org 0x0026		jmp Data_empty_interrupt
.org 0x0028		jmp TRNS_complete_interrupt


Data_empty_interrupt:
	in		r16, SREG
	push	r16

	ldi		r28, low(UDR0)
	ldi		r29, high(UDR0)
	st		Y, r18	; put the val into data register to send
	inc		r18

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

	ldi		r16, (0 << UMSEL01) | (0 << UMSEL00) | (0 << UPM01) | (0 << UPM00) | (0 << USBS0) | (1 << UCSZ01) | (1 << UCSZ00) ; choose async mode, disable parity, one stop bit, 8-bit of data
	ldi		r30, low(UCSR0C)
	ldi		r31, high(UCSR0C)
	st		Z, r16  ; set configuration

	ldi		r16, 103
	ldi		r30, low(UBRR0L)
	ldi		r31, high(UBRR0L)
	st		Z, r16

	;ldi		r16, (1 << RXCIE0) | (1 << RXEN0) ; enable receiver and receive interrupt
	;ldi		r30, low(UCSR0B)
	;ldi		r31, high(UCSR0B)
	;st		Z, r16

	ldi		r16, (1 << TXCIE0) | (1 << TXEN0) | (1 << UDRIE0) ; enable transmitter, transmitter and data empty interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	;ld		r17, Z
	;or		r16, r17	; turned off receiver and receive interrupt
	st		Z, r16

	ldi		r18, 0

	sei

loop:
	nop
	rjmp	loop
