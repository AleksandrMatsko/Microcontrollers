;
; Slave.asm
;
; Created: 21.05.2023 19:58:28
; Author : AMats
;

.DSEG

to_send:		.BYTE	1


.CSEG

.org 0x0000		jmp start
.org 0x0022		jmp SPI_complete_interrupt
.org 0x0026		jmp Data_empty_interrupt
.org 0x0028		jmp TRNS_complete_interrupt


SPI_complete_interrupt:
	in		r16, SREG
	push	r16

	in		r18, SPDR

	ldi		r30, low(to_send)
	ldi		r31, high(to_send)
	st		Z, r18

	ldi		r17, (1 << TXEN0) | (1 << UDRIE0); enable transmiter and data_empty_interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r17

	jmp		stop



Data_empty_interrupt:
	in		r16, SREG
	push	r16

	ldi		r30, low(to_send)
	ldi		r31, high(to_send)
	ld		r18, Z

	ldi		r28, low(UDR0)
	ldi		r29, high(UDR0)
	st		Y, r18		; put the val into data register to send

	cli

	ldi		r17, (1 << TXEN0) | (1 << TXCIE0); enable transmiter and transmitter interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r17

stop:
	pop		r16
	out		SREG, r16
	reti


TRNS_complete_interrupt:
	in		r16, SREG
	push	r16

	; turn off USART
	ldi		r17, 0
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r17

	rjmp	stop


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
	st		Z, r16 

	ldi		r16, 103
	ldi		r30, low(UBRR0L)
	ldi		r31, high(UBRR0L)
	st		Z, r16

    
	; SPI settings
	; turn on spi, big-endian, slave
	ldi		r16, (1 << SPIE) | (1 << SPE) | (0 << DORD) | (0 << MSTR) | (0 << CPOL) | (0 << CPHA) | (1 << SPR1) | (0 << SPR0)
	out		SPCR, r16

	ldi		r16, (1 << DDB5) | (1 << DDB4) | (0 << DDB2)
	out		DDRB, r16

	ldi		r16, (1 << PORTB5) | (1 << PORTB4) | (1 << PORTB3) | (1 << PORTB2)
	out		PORTB, r16

	sei

loop:
	nop
	rjmp	loop
