; ******************************************************************************
; ******************************************************************************
;
;		Name : 		error.asm
;		Purpose : 	Error Handler.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Handle Errors
;
; ******************************************************************************

SyntaxError:
		rerror 	"SYNTAX"
		
ErrorHandler:
		plx 								; pull address off.
		ply		
		inx 								; point to message
		bne 	_EHNoCarry
		iny
_EHNoCarry:		
		jsr 	PrintStringXY 				; print string at XY
		ldx 	#_EHMessage & $FF 			; print " AT "
		ldy 	#_EHMessage >> 8
		jsr 	PrintStringXY
		ldx 	lineNumber 					; convert line number
		ldy 	lineNumber+1
		jsr 	IntToString
		ldx 	#tokenBuffer & $FF 			; print number
		ldy 	#tokenBuffer >> 8
		jsr 	PrintStringXY
		jmp 	CompileTerminate
_EHMessage:
		.text	" AT ",0

; ******************************************************************************
;
;							Print String at (Y,X)
;
; ******************************************************************************

PrintStringXY:
		stx 	zTemp0
		sty 	zTemp0+1
		ldy 	#0
_PSLoop:lda 	(zTemp0),y
		beq 	_PSExit
		jsr 	PrintCharacter
		iny
		bra 	_PSLoop
_PSExit:rts

; ******************************************************************************
;
;							Print Character in A
;
; ******************************************************************************

PrintCharacter:
		pha
		phx
		phy
		jsr 	$FFD2
		ply
		plx
		pla
		rts
		
