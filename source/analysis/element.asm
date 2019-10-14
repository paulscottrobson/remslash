; ******************************************************************************
; ******************************************************************************
;
;		Name : 		element.asm
;		Purpose : 	Get current/Next element
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;						Get the current inline element
;
;			Returns CS if got, A type, YX data (see specification)
;
; ******************************************************************************

GetElement:
		ldx 	currentYX 					; get the current values.
		ldy 	currentYX+1
		lda 	currentType
		sec
		bne 	_GEExit 					; if current then exit
		;
		jsr 	GetNextElement 				; get the next element
		lda 	currentType 				; if one was got.
		bne 	GetElement 					; try again, it will pass now
		clc
_GEExit:
		rts
		
; ******************************************************************************
;
;							 Advance to next element
;
; ******************************************************************************

NextElement:
		stz 	currentType 				; clearing this will advance to the next one.
		rts

; ******************************************************************************
;
;		Worker function for above. Does the actual extraction, conversion
;		Puts results in currentType/currentYX. 
;		If fails currentType will be $00
;
; ******************************************************************************

GetNextElement:
		stz 	currentType 				; clear the current type in case there's nothing.
		jsr 	FindNextToken
		bcs 	_GNEData 					; if CS there's something to get.
		rts
_GNEData:
		.byte 	$FF
		;
		;		if character a quoted string, return that.
		;		if character a hexadecimal constant, return that.
		;		is character a known token/variable/procedure ? if so return that.
		;			(note, known identifiers/alpha tokens must terminate at that point)
		; 		is it a non-identifier character, if so, return that.
		;		extract the identifier.
		;		is it a decimal constant, if so convert and return that.
		;		return as an unknown identifier.
		;
		rts

; ******************************************************************************
;
;					Is A an identifier character ? CS if so.
;
; ******************************************************************************

IsCharIdentifier:
		cmp 	#"."						; dot always is.
		beq 	_ICIYes
		cmp 	#"0"						; check 0-9
		bcc 	_ICINo
		cmp 	#"9"+1
		bcc 	_ICIYes
		cmp 	#"A"						; check A-Z
		bcc 	_ICINo
		cmp 	#"Z"+1
		bcc 	_ICIYes
_ICINo:	clc
		rts
_ICIYes:sec
		rts
