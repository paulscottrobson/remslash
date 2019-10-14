; ******************************************************************************
; ******************************************************************************
;
;		Name : 		data.asm
;		Purpose : 	Data Allocation
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

		* = $0008
		.dsection zeroPage
		.cerror * > $7F,"Page Zero Overflow"
;
;		This allocation is for the *compiler only*
;
		.section zeroPage

codePtr:	.word ?							; code pointer (in BASIC code)
dictPtr:	.word ?							; next free space in user dictionary
objectPtr:	.word ?							; next free space for object code
varMemPtr:	.word ? 						; allocated variable space.

cStackPtr:	.word ? 						; compiler stack pointer

zTemp0:		.word ?							; temporary words
zTemp1:		.word ?
zTemp2: 	.word ?

tokenBufferSize = 16 						; max size of a token.
tokenBuffer:.fill tokenBufferSize+1 		; current token buffer as ASCIIZ
lineNumber:	.word ?							; current line number

currentType:.byte ?							; current type. $00 if should get one.
currentYX:	.word ?							; current XY value to return.

compileMode:.byte ? 						; compile mode (8 or 16 bits)

		.send

zeroPageStore = $0780 						; store for $00-$7F
comStack = $0700							; stack used when compiling
cStackSize = $80 							; size of compiler stack (max 128)

stackTemp = $06FF 							; stack temporary store.

TOKEN_REM = $8F 							; REM Token.

SMK_TOPSTACK = $FF 							; this marks the top of the compiler stack

ELT_PROCEDURE = $80 						; retrieved element types
ELT_VARIABLE = $08
ELT_UNKNOWNID = $01
ELT_CONSTANT = $02
ELT_STRING = $03
