;
; FindNumInArray.asm
;
; Created: 14.02.2023 14:30:33
; Author : AMats
;

.include "m168def.inc"

.def	_counter = r16
.def	_searched = r17
.def	_resultIndex = r18
.def	_tmp = r19

.equ	ARRAY_SIZE = 10
.equ	SEARCHED_VAL = 3
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
	push	r30
	push	r31
	ldi		_counter, 0
	ldi		r30, low(_array)
	ldi		r31, high(_array)
	
fill_element:
	cpi		_counter, ARRAY_SIZE
	breq	end_of_fill
	inc		_counter
	st		Z+, _counter
	jmp		fill_element

end_of_fill:
	pop		r31
	pop		r30
	pop		_counter
	pop		r15
	sts		SREG, r15
	ret

prepare_search:
	ldi		r30, low(_array)
	ldi		r31, high(_array)
	ldi		_counter, 0
	ldi		_searched, SEARCHED_VAL
	ldi		_resultIndex, NOT_FOUND
	
search:
	cpi		_counter, ARRAY_SIZE
	breq	search_end
	ld		_tmp, Z+
	cp		_tmp, _searched
	breq	found
	inc		_counter
	jmp		search

found:
	mov		_resultIndex, _counter

search_end:
	ldi	_counter, NOT_FOUND



