;
; WorkWithEEPROM.asm
;
; Created: 21.03.2023 14:29:31
; Author : AMats
;


.include "m168def.inc"

.def	_counter = r16
.def	_searched = r17
.def	_resultIndex = r18
.def	_tmp = r19

.equ	ARRAY_SIZE = 10
.equ	SEARCHED_VAL = 21
.equ	NOT_FOUND = -1

.DSEG

_array: .BYTE ARRAY_SIZE

.CSEG

.org $000 rjmp start

; Replace with your application code
start:
	call	fill_array
	jmp		prepare_search

fill_array:
	lds		r15, SREG
	push	r15
	push	_counter
	push	r20
	push	r21
	ldi		_counter, 0
	ldi		r20, 0
	ldi		r21, 0
	;ldi		r30, low(_array)
	;ldi		r31, high(_array)
	
fill_element:
	cpi		_counter, ARRAY_SIZE
	breq	end_of_fill
	inc		_counter

EEPROM_write:
	sbic	EECR, EEPE
	rjmp	EEPROM_write
	; Set up address in address register
	out		EEARH, r21; 
	out		EEARL, r20;
	inc		r20
	; Write data to Data Register
	out		EEDR, _counter
	; Write logical one to EEMPE
	sbi		EECR, EEMPE
	; Start EEPROM write by setting EEPE
	sbi		EECR, EEPE
	jmp		fill_element

end_of_fill:
	pop		r21
	pop		r20
	pop		_counter
	pop		r15
	sts		SREG, r15
	ret

prepare_search:
	ldi		r20, 0
	ldi		r21, 0
	ldi		_counter, 0
	ldi		_searched, SEARCHED_VAL
	ldi		_resultIndex, NOT_FOUND
	
search:
	cpi		_counter, ARRAY_SIZE
	breq	search_end

EEPROM_read:
	;ld		_tmp, Z+
	sbic	EECR, EEPE
	rjmp	EEPROM_read
	; Set up address in address register
	out		EEARH, r21; 
	out		EEARL, r20;
	inc		r20
	sbi		EECR,EERE
	; Read data from Data Register
	in		_tmp, EEDR
	cp		_tmp, _searched
	breq	found
	inc		_counter
	jmp		search

found:
	mov		_resultIndex, _counter

search_end:
	ldi		_counter, NOT_FOUND





