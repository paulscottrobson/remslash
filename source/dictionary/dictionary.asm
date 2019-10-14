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
;		Check Dictionaries for code at (codePtr). If successful, return
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
		sec 								; zTemp1 = codePtr - 5 ; this is because
		lda 	codePtr 					; the text data starts 5 bytes into the record.
		sbc 	#5
		sta 	zTemp1
		lda 	codePtr+1
		sbc 	#0
		sta 	zTemp1+1
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
		eor 	(zTemp1),y 					; does it match ? - $00 or $80 if so.
		asl 	a 							; put bit 7 into C.
		bne 	_DSSGoNext 					; if not, go to the next entry.
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
;		Create an entry in the user dictionary with the name in the 
;		tokenBuffer, data in YX and type in A.
;
; ******************************************************************************

DictionaryCreate:
		pha
		phx
		phy
		;
		phy 								; save data.high
		ldy 	#1							; write the type byte out.
		sta 	(dictPtr),y
		txa 								; write data low
		iny
		sta 	(dictPtr),y
		pla 								; write data high
		iny
		sta 	(dictPtr),y
		iny 								; Y is now 5 - copy token name.
_DCCopyName:
		lda 	tokenBuffer-5,y 			
		sta 	(dictPtr),y
		iny
		asl 	a
		bcc 	_DCCopyName
		;
		lda 	#0 							; write the zero marking dictionary end
		sta 	(dictPtr),y
		;
		tya 								; this is the offsest
		sta 	(dictPtr) 					; put as the first byte.
		;
		clc 								; add offset to dictptr
		adc 	dictPtr 					; updating the next free slot.
		sta 	dictPtr
		bcc 	_DCNoCarry
		inc 	dictPtr
_DCNoCarry:
		ply
		plx
		pla
		rts

