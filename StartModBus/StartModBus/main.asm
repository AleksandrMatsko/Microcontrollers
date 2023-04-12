;
; StartModBus.asm
;
; Created: 04.04.2023 14:29:35
; Author : AMats
;


.include "m168def.inc"
	
.equ	STOP_VAL = 2

.equ	ARRAY_SIZE = 10
.equ	BORDER = 9
.equ	MAX_PACKET_SIZE = 1

.DSEG

packet:			.BYTE	MAX_PACKET_SIZE
rcv_counter:	.BYTE	1
snd_counter:	.BYTE	1
array:			.BYTE	ARRAY_SIZE


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
	ld		r16, Z	; get data in r16

	ldi		r30, low(rcv_counter)
	ldi		r31, high(rcv_counter)
	ld		r17, Z
	inc		r17		; rcv_counter += 1

	cpi		r17, 1
	breq	first_byte

	; if not first byte

	ldi		r30, low(packet)
	ldi		r31, high(packet)
	ld		r18, Z		; get index
	
	ldi		r19, 0
	ldi		r28, low(array)
	ldi		r29, high(array)
	add		r28, r18
	adc		r29, r19
	st		Y, r16		; modified value by index
	
	jmp		turn_on_sender



first_byte:
	cpi		r16, ARRAY_SIZE	
	brsh	stop		; if num >= ARRAY_SIZE (index out of range) ignore

	st		Z, r17		; save rcv_counter

	ldi		r30, low(packet)
	ldi		r31, high(packet)
	st		Z, r16		; save index of element

	cpi		r16, BORDER
	brsh	stop		; if lower then BORDER we should send the value by index, if higher or equal receive val and set it by index

turn_on_sender:
	ldi		r17, 0
	;ldi		r30, low(snd_counter)
	;ldi		r31, high(snd_counter)
	;st		Z, r17		; snd_counter = 0

	ldi		r30, low(rcv_counter)
	ldi		r31, high(rcv_counter)
	st		Z, r17		; rcv_counter = 0

	cli

	ldi		r17, (1 << TXEN0) | (1 << UDRIE0) ; enable transmiter, data empty interrupt turn off receiver and receiver interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r17

	jmp		stop


Data_empty_interrupt:
	in		r16, SREG
	push	r16

	ldi		r30, low(packet)
	ldi		r31, high(packet)
	ld		r17, Z		; get index
	ldi		r18, 0

	ldi		r28, low(array)
	ldi		r29, high(array)
	add		r28, r17
	adc		r29, r18
	ld		r18, Y		; get val from memory on position [index]

	ldi		r28, low(UDR0)
	ldi		r29, high(UDR0)
	st		Y, r18		; put the val into data register to send

	cli

	ldi		r17, (1 << TXEN0) | (1 << TXCIE0); enable transmiter, transmitter interrupt and turned off data_empty_interrupt
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

	ldi		r16, (1 << RXEN0) | (1 << RXCIE0) ; enable receiver and receive interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r16

	rjmp	stop


fill_array:
	lds		r15, SREG
	push	r15
	push	r16
	push	r30
	push	r31
	ldi		r16, 0		; counter
	ldi		r30, low(array)
	ldi		r31, high(array)
	
fill_element:
	cpi		r16, ARRAY_SIZE
	breq	end_of_fill
	inc		r16
	st		Z+, r16
	jmp		fill_element

end_of_fill:
	pop		r31
	pop		r30
	pop		r16
	pop		r15
	sts		SREG, r15
	ret


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

	ldi		r16, (1 << RXEN0) | (1 << RXCIE0)  ; enable receiver and receive interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r16

	sei

	call	fill_array


loop:
	nop
	rjmp	loop
