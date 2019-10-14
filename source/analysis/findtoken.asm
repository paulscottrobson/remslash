; ******************************************************************************
; ******************************************************************************
;
;		Name : 		findtoken.asm
;		Purpose : 	Find the next token, if any.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		Advances codePtr to the next token. Return CS if found,CC for end.
;
; ******************************************************************************

FindNextToken:	
		pha
		phx
		phy
		lda 	(codePtr) 					; check not at end of line.
		bne  	_FNTNotEOL					; not end of line.
		;
		;		End of line. Check not end of actual program, and
		;		skip forward looking for the next REM/ line.
		;
_FNTEndOfLine:
		inc16 	codePtr 					; advance to offset word.
_FNTNextLine:		
		lda 	(codePtr) 					; if the offset word is zero.
		ldy 	#1 							; then exit
		ora 	(codePtr)
		bne 	_FNTNotEndProgram
		clc 								; exit with carry clear == fail.
		jmp 	_FNTExit
		;
		;		New line found.
		;
_FNTNotEndProgram:
		ldy 	#5 							; the 5th character (2nd in line) must
		lda 	(codePtr),y 				; be a slash.		
		cmp 	#"/"
		bne 	_FNTGoNextLine
		;
		dey		 							; check for REM at the start of the line.
		lda 	(codePtr),y
		cmp 	#TOKEN_REM
		beq 	_FNTFoundCode 				; if so then we have found REM/
		;
		cmp 	#"/" 						; if first character is /, then this is //		
		bne 	_FNTGoNextLine
		;
		lda 	#TOKEN_REM 					; convert it to REM/
		sta 	(codePtr),y
		bra 	_FNTFoundCode 				; and carry on as found code.
		;
		;		Current line is not REM/ or // , so try next line.
		;
_FNTGoNextLine:		
		ldy 	#1 							; read MSB to link through
		lda 	(codePtr),y
		tax
		lda 	(codePtr) 					; read LSB
		sta 	codePtr 					; follow link.
		stx 	codePtr+1
		bra 	_FNTNextLine 				; go through to next line.
		;
		;		Found a line which begins REM/
		;
_FNTFoundCode:
		ldy 	#2 							; copy current line number so the error 
		lda 	(codePtr),y 				; handler knows the line to report.
		sta 	lineNumber
		iny
		lda 	(codePtr),y
		sta 	lineNumber+1
		iny
		;
		clc
		lda 	codePtr 					; add 6 to the codePtr. 
		adc 	#6							; (<offset>,<line#>,REM token, slash)
		sta 	codePtr
		bcc 	_FNTNotEOL
		inc 	codePtr+1
		;
		;		codePtr points to actual code.
		;
_FNTNotEOL:		
		lda 	(codePtr) 					; read byte at codePtr
		beq 	_FNTEndOfLine 				; if zero goto the next line.
		cmp 	#" "						; is it space ?
		bne 	_FNTNotSpace 				; found a non space character, start extracting.
		;
		inc16 	codePtr 					; space - go past it and loop round
		bra 	_FNTNotEOL
		;
		;		Found a non-space character
		;
_FNTNotSpace:
		sec 								; set carry to signify token found.
_FNTExit:
		ply
		plx
		pla
		rts
