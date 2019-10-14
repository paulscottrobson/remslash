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
;			 Get an element, throw an error if missing, skip it
;
; ******************************************************************************

GetElementNext:
		jsr 	GetElement 					; get the element
		bcc 	_GENError 					; nothing
		jsr 	NextElement 				; skip it
		rts
_GENError:
		rerror	"MISSING"

; ******************************************************************************
;
;		Worker function for above. Does the actual extraction, conversion
;		Puts results in currentType/currentYX. 
;		If fails currentType will be $00
;
;		1) Checks to see if it is a quoted string
;		2) If $ found, it expects a hexadecimal constant.
;		3) If a non-identifier character is found, it first matches 2 then
; 		   1 characters against the dictionaries ; otherwise it returns it
;		   as an untokenised character
;		4) It sees if the identifier is known, and returns appropriate codes
;		   for defined variables, constants and tokens.
;		5) It tries to convert to a decimal constant
;		6) It returns an unknown identifier.
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
		;		If character is not alphanumeric, try the first two,
		;		then the first against the dictionary, if no matches
		;		return the first as a character.
		;
		; -------------------------------------------------------------------
_GNENotHexadecimal:
		lda 	(codePtr) 					; is the first character alphanumeric ?
		jsr 	IsCharIdentifier
		bcs 	_GNEIsAlphaNumeric
		;
		ldy 	#1 							; try the first 2 characters
		lda 	(codePtr)
		sta 	tokenBuffer
		lda 	(codePtr),y
		ora 	#$80
		sta 	tokenBuffer+1
		jsr 	DictionarySearch
		bcs 	_GNECTFound 				
		;
		lda 	tokenBuffer 				; try the first character only
		ora 	#$80
		sta 	tokenBuffer
		jsr 	DictionarySearch
		bcs 	_GNECTFound 				

		lda 	(codePtr)					; just return the token as a single char.
		cmp 	#$40 						; it cannot be in the range 40-7F.
		bcs 	_GNECTSyntax
		ldy 	#1
		jmp 	_GNEExit		
		;
_GNECTFound:
		stx 	zTemp0 						; address in zTemp0
		sty 	zTemp0+1
		ldy 	#2 							; get the token
		lda 	(zTemp0),y
		pha  								; save it
		ldy 	#1
		lda 	tokenBuffer 				; first char of token buffer
		bmi 	_GNECTGotSize 				; if bit 7 set 1 character matched
		iny
_GNECTGotSize:	
		pla 								; restore the token.
		jmp 	_GNEExit		

_GNECTSyntax:
		jmp 	SyntaxError

		; -------------------------------------------------------------------
		;
		;		Alphanumeric. See if it is a known identifier.
		;
		; -------------------------------------------------------------------
_GNEIsAlphaNumeric:
		jsr 	ExtractAlphaNumericToken 	; pull an alphanumeric token -> buffer.
		pha 								; save token length on stack.	
		;
		jsr 	DictionarySearch 			; figure out what it is ?
		bcc 	_GNEIsUnknown
		;
		stx 	currentYX 					; this value is returned, save it.
		sty 	currentYX+1
		;
		and 	#$80 						; if it is 1xxx xxxx then do it with $80
		bne 	_GNEDoElement				; (this is a procedure) 
		;
		ldy 	#1 							; get type
		lda 	(currentYX),y
		and 	#$F8 						; if it is $08-$0F then it is a variable
		cmp		#$08 						; so 1111 1xxx masked, then check it is 
		beq		_GNEDoElement 				; 0000 1xxx. This returns 8, known variable code.
		;
		;
		lda 	(currentYX),y 				; otherwise it must be a token.
		cmp 	#1
		bne 	_GNEInternal 				; otherwise we have a problem .....
		;
		iny
		lda 	(currentYX),y				; token in A
_GNEDoElement:		
		ply 								; length in Y
		jmp 	_GNEExit
;
_GNEInternal:		 						; illegal value in dictionary ?
		rerror 	"I#0" 					
		; -------------------------------------------------------------------
		;
		;		There is now an identifier in the token buffer whose length
		;		is pushed on the stack. It is either a decimal constant, or
		;		an unknown identifier.
		;
		; -------------------------------------------------------------------

_GNEIsUnknown:
		lda 	#10 						; try converting it to base 10
		jsr 	ConstantToInteger 			; convert to integer
		bcs 	_GNEIsInteger 				; it converted ok.
		;
		set16 	currentYX,tokenBuffer 		; unknown, so return that
		lda 	#ELT_UNKNOWNID
		ply
		bra 	_GNEExit 				
;
_GNEIsInteger:
		stx 	currentYX 					; save the resulting integer
		sty 	currentYX+1
		lda 	#ELT_CONSTANT 				; and return a constant
		ply
		bra 	_GNEExit

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

