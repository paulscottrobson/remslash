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
		; -------------------------------------------------------------------
		;
		;				   Check for a quoted string. "xxx"
		;
		; -------------------------------------------------------------------
		lda 	(codePtr)
		cmp 	#'"'
		bne 	_GNENotQString
		;
		clc 								; set currentYX to the following character
		lda 	codePtr 					; (e.g. the start of the string.)
		adc 	#1
		sta 	currentYX
		lda 	codePtr+1
		adc 	#0
		sta 	currentYX+1
		;
		ldy 	#0 							; skip forward to next quote
_GNEQSkip:
		iny
		lda 	(codePtr),y
		beq 	_GNENoQuote 				; missing closing quote
		cmp 	#'"'		
		bne 	_GNEQSkip
		iny 								; Y is the amount to skip
		lda 	#ELT_STRING
		jmp 	_GNEExit
_GNENoQuote: 								; there was no closing quote.	
		rerror	"MISSING QUOTE"	
		; -------------------------------------------------------------------
		;
		;				  Check for a hexadecimal constant $xxx
		;
		; -------------------------------------------------------------------
_GNENotQString:
		cmp 	#"$"						; is there a dollar, the hex constant marker.
		bne 	_GNENotHexadecimal
		jsr 	IncCodePtr 					; point to next token.
		jsr 	ExtractAlphaNumericToken 	; pull an alphanumeric token -> buffer.
		pha 								; save length
		lda 	#16 						; use base 16.
		jsr 	ConstantToInteger 			; convert to integer
		bcc 	_GNEBadHex 					; failed
		stx 	currentYX
		sty 	currentYX+1
		ply 								; length in Y
		lda 	#ELT_CONSTANT 				; it's a constant
		jmp 	_GNEExit
_GNEBadHex: 								; not legitimate hex constant.
		rerror 	"BAD HEX"
		; -------------------------------------------------------------------
		;
		;			 Search the dictionary for the current word.
		;
		; -------------------------------------------------------------------
_GNENotHexadecimal:
		jsr 	DictionarySearch
		bcc 	_GNENotKnown 
		stx 	zTemp0 						; save entry address.
		sty 	zTemp0+1
		ldy 	#4 							; find how long it is, +5
_GNEGetLength:
		iny
		lda 	(zTemp0),y
		bpl 	_GNEGetLength
		;
		tya 								; actual token length
		sec
		sbc 	#5-1
		pha 								; save length on the stack.
		;
		ldy 	#2							; copy the data to the XY
		lda 	(zTemp0),y
		sta 	currentYX
		iny
		lda 	(zTemp0),y
		sta 	currentYX+1
		;
		ldy 	#1 							; get type
		lda 	(zTemp0),y
		and 	#$C0 						; is it a procedure 11xxx xxxx
		cmp 	#$C0 			
		beq 	_GNETokenType 				; if so, exit with type $C0
		;
		lda 	(zTemp0),y 					; get type and clear bit 7
		and 	#$7F
		beq 	_GNETokenType 				; was $00 or $80, local/global.
		dec 	a 
		beq 	_GNEIsToken 				; if $01, then it is a token.		
		;
		rerror 	"?INTL" 					; this should happen.

_GNEIsToken:
		lda 	currentYX 					; return the token itself.
_GNETokenType:
		ply 								; length into Y
		bra 	_GNEExit

_GNENotKnown:

		; -------------------------------------------------------------------
		;
		;		Successful element get. A is the current type. Y is the
		;		number of characters to consume.
		;
		; -------------------------------------------------------------------
_GNEExit:
		sta 	currentType 				; save current type
		tya 								; add skip to code pointer
		clc
		adc 	codePtr
		sta 	codePtr
		bcc 	_GNENoCarry
		inc 	codePtr+1
_GNENoCarry:
		rts

; ******************************************************************************
;
;		  Get an alphanumeric token into the token buffer. Length in A
;
; ******************************************************************************

ExtractAlphaNumericToken:
		phx
		phy
		ldy 	#255 						; start position-1
_EANTLoop:
		iny 								; bump index
		cpy 	#tokenBufferSize 			; check if too big.
		beq 	_EANTLength
		lda 	(codePtr),y 				; copy character
		sta 	tokenBuffer,y
		jsr 	IsCharIdentifier 			; if identifier go round again
		bcs 	_EANTLoop
		;
		cpy 	#0 							; no token ???
		beq 	_EANTLength
		;
		lda 	tokenBuffer-1,y 			; set bit 7 of last character
		ora 	#$80
		sta 	tokenBuffer-1,y
		;
		lda 	#0 							; make it ASCIIZ
		sta 	tokenBuffer,y
		tya 								; return length in A.
		ply
		plx
		rts

_EANTLength: 								; identifier too long for buffer.
		rerror	"TOKEN"

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

		;
		; 		is it a non-identifier character, if so, return that.
		;		extract the identifier.
		;		is it a decimal constant, if so convert and return that.
		;		return as an unknown identifier.
		;
		rts
