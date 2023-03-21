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
	ldi		_counter, 0
	ldi		r30, low(_array)
	ldi		r31, high(_array)
	
fill_array:
	cpi		_counter, ARRAY_SIZE
	breq	prepare_search
	inc		_counter
	st		Z+, _counter
	jmp		fill_array

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


