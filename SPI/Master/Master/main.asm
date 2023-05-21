;
; Master.asm
;
; Created: 16.05.2023 15:19:54
; Author : AMats
;


.include "m168def.inc"
	

.DSEG

to_send:		.BYTE	1

.CSEG

.org 0x0000		jmp start
.org 0x0022		jmp SPI_complete_interrupt
.org 0x0024		jmp RCV_complete_interrupt


RCV_complete_interrupt:
	in		r16, SREG
	push	r16

	ldi		r30, low(UDR0)
	ldi		r31, high(UDR0)
	ld		r19, Z	; get data in r16

	ldi		r30, low(to_send)
	ldi		r31, high(to_send)
	st		Z, r19

	; TODO turn on SPI
	; set low on SS
	in		r17, PORTB
	andi	r17, ~(1 << PORTB2)
	out		PORTB, r17

	; place data to send
	out		SPDR, r19

	; turn off USART
	ldi		r16, (0 << RXEN0) | (0 << RXCIE0)  ; enable receiver and receive interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r16

stop:
	pop		r16
	out		SREG, r16
	reti


SPI_complete_interrupt:
	in		r16, SREG
	push	r16

	; set SS high
	in		r17, PORTB
	ori	r17, (1 << PORTB2)
	out		PORTB, r17

	; turn on USART
	ldi		r16, (1 << RXEN0) | (1 << RXCIE0)  ; enable receiver and receive interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r16

	jmp		stop
	

start:
    cli
		
	ldi		r16, low(RAMEND)
	out		SPL, r16
	ldi		r16, high(RAMEND)
	out		SPH, r16

	; USART settings
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

	ldi		r16, (1 << RXEN0) | (1 << RXCIE0)  ; enable receiver and receive interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r16

	; SPI settings
	; turn on spi, big-endian, master
	ldi		r16, (1 << SPIE) | (1 << SPE) | (0 << DORD) | (1 << MSTR) | (0 << CPOL) | (0 << CPHA) | (1 << SPR1) | (0 << SPR0)
	out		SPCR, r16

	ldi		r16, (1 << DDB5) | (1 << DDB3) | (1 << DDB2)
	out		DDRB, r16

	ldi		r16, (1 << PORTB5) | (1 << PORTB4) | (1 << PORTB3) | (1 << PORTB2)
	out		PORTB, r16

	sei

loop:
	nop
	rjmp	loop




