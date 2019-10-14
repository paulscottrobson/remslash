; ******************************************************************************
; ******************************************************************************
;
;		Name : 		compiler.asm
;		Purpose : 	Compiler Main Program
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;							Compile current BASIC file
;
; ******************************************************************************

Compiler:
		tsx 										; save stack pointer
		stx 	stackTemp
		;
		jsr 	StateSave 							; save zero page and stack
		;
		;		Set up pointers and clear user dictionary.
		;
		set16	codePtr,SourceCode-1 				; point at the $00 before the program
													; which makes the scanner think of line end.

		set16 	dictPtr,UserDictionary				; next free slot in user dictionary.
		stz 	UserDictionary 						; clear the user dictionary.

		set16 	objectPtr,UserCode 					; next free slot for executable P-Code.

		set16 	cStackPtr,comStack+cStackSize-1 	; reset the compiler stack pointer.
		lda 	#SMK_TOPSTACK 						; put a dummy value to pop.
		sta 	(cStackPtr)

		stz 	currentType 						; current type cleared to get first.

		jsr 	GetElement
		
CompileTerminate:		
		ldx 	stackTemp 							; restore the stack pointer
		txs
		jsr 	StateRestore 						; restore ZPage and Exit.
		rts

