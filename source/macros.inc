; ******************************************************************************
; ******************************************************************************
;
;		Name : 		macros.inc
;		Purpose : 	Convenient Macros
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************
;
;		set16 addr,data 	sets addr to 16 bit constant
;
set16	.macro
		lda 	#(\2) & $FF
		sta 	\1
		lda 	#(\2) >> 8
		sta 	\1+1
		.endm		
;
;		inc16 addr 			increment 16 bit value
;
inc16 	.macro
		inc 	\1
		bne 	_NoCarry
		inc 	\1+1
_NoCarry:
		.endm
;
;		error handler.
;
rerror 	.macro
		jsr 	ErrorHandler
		.text 	\1,$00
		.endm
