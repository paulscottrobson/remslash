; ******************************************************************************
; ******************************************************************************
;
;		Name : 		dictionary.asm
;		Purpose : 	Dictionary Search/Create
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		Check Dictionaries for code in tokenBuffer. If successful, return
;		CS and dictionary entry in XY, type in A. If failed, return CC.
;		
; ******************************************************************************

DictionarySearch:
		ldx		#UserDictionary & $FF 		; search user dictionary
		ldy 	#UserDictionary >> 8
		jsr 	DictionarySearchSingle
		bcs 	_DSExit 					; successful ?
		ldx 	#StandardDictionary & $FF 	; search compiler dictionary
		ldy 	#StandardDictionary >> 8
		jsr 	DictionarySearchSingle
_DSExit:
		rts
;
;		Search dictionary at XY for token, as above. Don't use this !
;
DictionarySearchSingle:
		stx 	zTemp0 						; save search dictionary address
		sty 	zTemp0+1
		;
		;		Main search loop
		;
_DSSLoop:
		lda 	(zTemp0)					; reached the end ?
		bne 	_DSSEntry
		clc 								; return with carry clear
		rts
		;
		;		Compare the names in the buffer and dictionary.
		;
_DSSEntry:
		ldy 	#5 							; compare the names. Dictionary offset starts at five.
_DSSCompare:
		lda 	(zTemp0),y 					; get corresponding character out (back 5)		
		cmp 	TokenBuffer-5,y 			; does it match ? - $00 or $80 if so.
		bne 	_DSSGoNext 					; if not, go to the next entry.
		asl 	a 							; put bit 7 into C.
		iny 								; point to next character.
		bcc 	_DSSCompare 				
		;
		ldy 	#1 							; type into A.
		lda 	(zTemp0),y
		ldx 	zTemp0 						; successful, so return address in XY and carry set.
		ldy 	zTemp0+1
		sec
		rts
		;
		;		Compare failed, advance to next entry.
		;
_DSSGoNext:
		clc
		lda 	(zTemp0)					; offset, add it to current address.
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_DSSLoop
		inc 	zTemp0+1
		bra 	_DSSLoop

; ******************************************************************************
;
;		Create an entry in the user dictionary using the name at YX. 
;		Returns address of new record in YX.
;
; ******************************************************************************

DictionaryCreate:
		pha
		;
		txa			 						; save address of name, with 5 deducted.
		sec 								; this is because of the offset in the 
		sbc 	#5 							; record.
		sta 	zTemp0
		tya
		sbc 	#0
		sta 	zTemp0+1 

		ldy 	#1							; write three bytes of $00
		lda 	#0
		sta 	(dictPtr),y
		iny
		sta 	(dictPtr),y
		iny
		sta 	(dictPtr),y
		iny 								; Y is now 5 - copy token name.
_DCCopyName:
		lda 	(zTemp0),y 			
		sta 	(dictPtr),y
		iny
		asl 	a
		bcc 	_DCCopyName
		;
		lda 	#0 							; write the zero marking dictionary end
		sta 	(dictPtr),y
		;
		tya 								; this is the offset
		sta 	(dictPtr) 					; put as the first byte.
		;
		ldx 	dictPtr 					; load address into YX
		ldy 	dictPtr+1
		;
		clc 								; add offset to dictptr
		adc 	dictPtr 					; updating the next free slot.
		sta 	dictPtr
		bcc 	_DCNoCarry
		inc 	dictPtr
_DCNoCarry:
		pla
		rts

