;
; MatrixKeyboard.asm
;
; Created: 25.04.2023 14:32:50
; Author : AMats
;


.include "m168def.inc"
	
.equ	line_0 = 0b00000001
.equ	line_1 = 0b00000010
.equ	line_2 = 0b00000100
.equ	line_3 = 0b00001000

.equ	column_0 = 0b01000000
.equ	column_1 = 0b00100000
.equ	column_2 = 0b00010000
.equ	default_val = 0b01110000

.equ	ascii_0 = 48
.equ	ascii_1 = 49
.equ	ascii_2 = 50
.equ	ascii_3 = 51
.equ	ascii_4 = 52
.equ	ascii_5 = 53
.equ	ascii_6 = 54
.equ	ascii_7 = 55
.equ	ascii_8 = 56
.equ	ascii_9 = 57
.equ	star_ascii = 42
.equ	grid_ascii = 35


.equ	POLL_TIMEOUT = 7
.equ	DELAY_TIMEOUT = 1

.DSEG


to_send:	.BYTE 1

.CSEG

.org 0x0000		rjmp start
;.org 0x001E		rjmp TC0_cmp_handler
.org 0x000a		rjmp PCINT2_handler
.org 0x0012		rjmp TC2_overflow_handler
.org 0x0020		rjmp TC0_overflow_handler
.org 0x0026		jmp Data_empty_interrupt
.org 0x0028		jmp TRNS_complete_interrupt


PCINT2_handler:
	in		r16, SREG
	push	r16

; start timer counter 0
	ldi		r22, 0
	out		TCNT0, r22

	ldi		r16, (0 << PCIE2)
	ldi		r30, low(PCICR)
	ldi		r31, high(PCICR)
	st		Z, r16

	ldi		r16, (0 << TOIE2)
	ldi		r30, low(TIMSK2)
	ldi		r31, high(TIMSK2)
	st		Z, r16

	ldi		r16, (1 << TOIE0) ; turn on timer counter 0
	ldi		r30, low(TIMSK0)
	ldi		r31, high(TIMSK0)
	st		Z, r16

	jmp		stop

TC2_overflow_handler: ; polling
	in		r16, SREG
	push	r16

	in		r17, PORTC
	cpi		r17, (1 << PORTC3)
	breq	return_to_PC0
	lsl		r17
	out		PORTC, r17

	jmp		restore_pin_change

return_to_PC0:
	ldi		r17, (1 << PORTC0)
	out		PORTC, r17

	jmp		restore_pin_change

TC0_overflow_handler:
	in		r16, SREG
	push	r16
	
	in		r17, PIND
	in		r18, PINC

	ldi		r16, (0 << TOIE0) ; turn off timer counter
	ldi		r30, low(TIMSK0)
	ldi		r31, high(TIMSK0)
	st		Z, r16

	cpi		r17, default_val
	brne	analyse
	jmp		restore_TCNT2

; analyse value
analyse:
	mov		r20, r17	; for debug
	mov		r21, r18	; for debug

	ldi		r28, low(to_send)
	ldi		r29, high(to_send)
	
	cpi		r18, line_0
	breq	first_line
	cpi		r18, line_1
	breq	second_line
	cpi		r18, line_2
	breq	third_line
	cpi		r18, line_3
	breq	fourth_line
	jmp		restore_TCNT2

first_line:
	cpi		r17, column_0
	breq	one
	cpi		r17, column_1
	breq	two
	cpi		r17, column_2
	breq	three
	jmp		restore_TCNT2

second_line:
	cpi		r17, column_0
	breq	four
	cpi		r17, column_1
	breq	five
	cpi		r17, column_2
	breq	six
	jmp		restore_TCNT2

third_line:
	cpi		r17, column_0
	breq	seven
	cpi		r17, column_1
	breq	eight
	cpi		r17, column_2
	breq	nine
	jmp		restore_TCNT2

fourth_line:
	cpi		r17, column_0
	breq	star
	cpi		r17, column_1
	breq	zero
	cpi		r17, column_2
	breq	grid
	jmp		restore_TCNT2

one:
	ldi		r19, ascii_1
	jmp		prepare_to_transfer

two:
	ldi		r19, ascii_2
	jmp		prepare_to_transfer

three:
	ldi		r19, ascii_3
	jmp		prepare_to_transfer

four:
	ldi		r19, ascii_4
	jmp		prepare_to_transfer

five:
	ldi		r19, ascii_5
	jmp		prepare_to_transfer

six:
	ldi		r19, ascii_6
	jmp		prepare_to_transfer

seven:
	ldi		r19, ascii_7
	jmp		prepare_to_transfer

eight:
	ldi		r19, ascii_8
	jmp		prepare_to_transfer

nine:
	ldi		r19, ascii_9
	jmp		prepare_to_transfer

star:
	ldi		r19, star_ascii
	jmp		prepare_to_transfer

zero:
	ldi		r19, ascii_0
	jmp		prepare_to_transfer

grid:
	ldi		r19, grid_ascii
	jmp		prepare_to_transfer

prepare_to_transfer:
	st		Y, r19

	ldi		r17, (1 << TXEN0) | (1 << UDRIE0) ; enable transmiter, data empty interrupt 
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r17
	jmp		stop

restore_TCNT2:
	ldi		r22, 0
	ldi		r30, low(TCNT2)
	ldi		r31, high(TCNT2)
	st		Z, r22

	ldi		r16, (1 << TOIE2)
	ldi		r30, low(TIMSK2)
	ldi		r31, high(TIMSK2)
	st		Z, r16

restore_pin_change:
	ldi		r16, (1 << PCIE2)
	ldi		r30, low(PCICR)
	ldi		r31, high(PCICR)
	st		Z, r16
	rjmp	stop
	
stop:	
	pop		r16
	out		SREG, r16
	reti


Data_empty_interrupt:
	in		r16, SREG
	push	r16

	ldi		r28, low(to_send)
	ldi		r29, high(to_send)
	ld		r18, Y		; get val from memory on position [index]

	ldi		r28, low(UDR0)
	ldi		r29, high(UDR0)
	st		Y, r18		; put the val into data register to send

	cli

	ldi		r17, (1 << TXEN0) | (1 << TXCIE0); enable transmiter, transmitter interrupt and turned off data_empty_interrupt
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r17

	rjmp	stop


TRNS_complete_interrupt:
	in		r16, SREG
	push	r16

	ldi		r16, 0 ; turn off
	ldi		r30, low(UCSR0B)
	ldi		r31, high(UCSR0B)
	st		Z, r16

	ldi		r16, (1 << PCIE2)
	ldi		r30, low(PCICR)
	ldi		r31, high(PCICR)
	st		Z, r16

	rjmp	stop



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

; turn on output
	ldi		r16, (1 << DDC3) | (1 << DDC2) | (1 << DDC1) | (1 << DDC0)
	out		DDRC, r16
	ldi		r16, (0 << PORTC3) | (0 << PORTC2) | (0 << PORTC1) | (0 << PORTC0)
	out		PORTC, r16

; turn on input
	ldi		r16, (0 << DDD4) | (0 << DDD5) | (0 << DDD6) 
	out		DDRD, r16
	ldi		r16, (0 << PORTD4) | (0 << PORTD5) | (0 << PORTD6)
	out		PORTD, r16

	ldi		r17, (1 << PORTC0)
	out		PORTC, r17

	ldi		r16, (1 << PUD)
	ldi		r30, low(MCUCR)
	ldi		r31, high(MCUCR)
	st		Z, r16


; prepare for timer/counter interrupts
; normal mode
	ldi		r16, (0 << WGM02) | (0 << CS02) | (1 << CS01) | (0 << CS00) ; clk / 8
	out		TCCR0B, r16
	ldi		r16, (0 << COM0B1) | (0 << COM0B0) | (0 << WGM01) | (0 << WGM00)
	out		TCCR0A, r16

	ldi		r16, (0 << WGM22) | (1 << CS22) | (0 << CS21) | (1 << CS20) ; clk / 1024
	ldi		r30, low(TCCR2B)
	ldi		r31, high(TCCR2B)
	st		Z, r16
	ldi		r16, (0 << COM2B1) | (0 << COM2B0) | (0 << WGM21) | (0 << WGM20)
	ldi		r30, low(TCCR2A)
	ldi		r31, high(TCCR2A)
	st		Z, r16

	ldi		r16, (1 << TOIE2)
	ldi		r30, low(TIMSK2)
	ldi		r31, high(TIMSK2)
	st		Z, r16

	ldi		r16, (1 << PCIE2)
	ldi		r30, low(PCICR)
	ldi		r31, high(PCICR)
	st		Z, r16

	ldi		r16, (1 << PCINT22) | (1 << PCINT21) | (1 << PCINT20)
	ldi		r30, low(PCMSK2)
	ldi		r31, high(PCMSK2)
	st		Z, r16

	sei


cycle:
	nop
	jmp		cycle

