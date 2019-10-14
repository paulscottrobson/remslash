; ******************************************************************************
; ******************************************************************************
;
;		Name : 		byteword.asm
;		Purpose : 	Handle Byte/Word keywords
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;							  Byte/Word Handlers
;
; ******************************************************************************

ByteHandler: ;; [byte]
		lda 	#1
		bra 	ByteWordCode
WordHandler: ;; [word]
		lda 	#2
		bra 	ByteWordCode
;
;		General handler.
;
ByteWordCode:
		jsr 	CreateVariable 				
		bcs		_GoProcDef
		rts

_GoProcDef:
		; TODO: Go to Procedure Definition code.		
		.byte 	$FF
		.byte 	$FF

; ******************************************************************************
;
;		Create variable using next element. Type is in A (1/byte 2/word)
;		Return record of new variable/procedure in XY.
;		Return CS if it is a procedure definition, CC if it's a variable.
;
; ******************************************************************************

CreateVariable:
		pha 								; save on stack.
		jsr 	GetElementNext 				; get and skip element, fail if missing.
		cmp 	#ELT_UNKNOWNID 				; anything other than unknown, then exit.
		bne		_CVDuplicate 				; it already exists.
		;
		jsr 	DictionaryCreate 			; create an empty entry for it.
		;
		pla 								; restore size
		phx 								; save new record address on the stack.
		phy 
		pha 								; save size on top of the stack
		;
		jsr 	GetElement 					; see what's next.
		bcc 	_CVNotSetAddress 			; if nothing, then no address
		;
		cmp 	#KWD_LPAREN					; we are looking for @ or (
		bne 	_CVNotProcedure 			; if ( it is a procedure.
		;
		pla 								; throw the length, which we do not need.
		ply 								; pull record address off.
		plx
		sec 								; signify a procedure definition
		rts
		;
		;		Handle <type> <identifier> @ <address>
		;
_CVNotProcedure:
		cmp 	#KWD_AT 					; is it a variable address marker.
		bne 	_CVNotSetAddress
		;
		jsr 	GetElementNext 				; skip over the @
		jsr 	GetElementNext 				; get what follows.
		cmp 	#ELT_CONSTANT
		bne 	_CVAddress 					; fail if not a constant.
		bra 	_CVCreate
		;
		;		Handle <type> <identifier> system allocates address.
		;
_CVNotSetAddress:
		pla 								; restore the length.
		pha
		ldx 	varMemPtr 					; use the current variable memory pointer
		ldy 	varMemPtr+1
		;
		clc 								; add length to the variable memory pointer
		adc 	varMemPtr
		sta 	varMemPtr
		bcc		_CVCreate
		inc 	varMemPtr
		bra 	_CVCreate

_CVAddress:									; address must be constant
		rerror 	"VAR ADDRESS"
_CVDuplicate:								; duplicate name.
		rerror 	"NAME"
		;
		;		Create a variable. The address is in XY. The stack contains the
		;		record (low) record (high) and bytes required.
		;
_CVCreate:
		pla 								; save size in zTemp1
		sta 	zTemp1
		pla 								; set zTemp0 to point to the record
		sta 	zTemp0+1
		pla
		sta 	zTemp0
		;
		tya
		ldy 	#3 							; save address in data slot
		sta 	(zTemp0),y
		txa
		dey
		sta 	(zTemp0),y
		;
		lda		zTemp1 						; 1 if byte, 2 if word
		dec 	a 							; 0 if byte, 1 if word
		asl 	a 							; 0 if byte, 2 if word.
		ora 	#8 							; make it 10s0, which is a local variable
		ldy 	#1
		sta 	(zTemp0),y
		;
		ldy 	#4 							; scan through the name looking for a '.'
_CVCheckIsGlobal:
		iny
		lda 	(zTemp0),y 					; get character
		and 	#$7F 						; is it a '.' character
		cmp 	#'.'
		beq 	_CVIsGlobal
		lda 	(zTemp0),y 
		bpl 	_CVCheckIsGlobal 			; reached the end
		bra 	_CVExit
		;
_CVIsGlobal:
		ldy 	#1 							; found a '.', so it's a global variable
		lda 	(zTemp0),y 					; so we set bit 2 which indicates this
		ora 	#$04 						; in the type byte
		sta 	(zTemp0),y
		;
_CVExit:
		ldx 	zTemp0 						; record in XY
		ldy 	zTemp0+1
		lda 	zTemp1 						; size back from A
		clc									; carry clear, it was a variable
		rts
