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
													; which makes the scanner think line end.

		set16 	dictPtr,UserDictionary				; next free slot in user dictionary.
		stz 	UserDictionary 						; clear the user dictionary.

		set16 	objectPtr,UserCode 					; next free slot for executable P-Code.

		set16 	cStackPtr,comStack+cStackSize-1 	; reset the compiler stack pointer.
		lda 	#SMK_TOPSTACK 						; put a dummy value to pop.
		sta 	(cStackPtr)

		set16 	varMemPtr,VariableMemory 			; set the variable memory pointer
		
		stz 	currentType 						; current type cleared to get first.

		lda 	#8 			 						; set compile mode to 8 bit.
		sta 	compileMode
		;
		;		Main Compiler loop
		;
CompileLoop:
		jsr 	GetElement 							; get the current element
		cmp 	#$40 								; check in range $40-$7F (e.g. a token)
		bcc 	CompileNotToken 			
		cmp 	#$80
		bcs 	CompileNotToken
		;
		;		Handle a token.
		;
		jsr 	NextElement 						; skip this element
		and 	#$3F 								; in range $00-$3F now
		asl 	a 									; doubled, index into vector table
		tax 										; use it as index into vector table.
		;
		lda 	TokenVectors,x 						; copy target address to zTemp0
		sta 	zTemp0
		lda 	TokenVectors+1,x
		sta 	zTemp0+1
		jsr 	CallZTemp0 							; call it
		bra 	CompileLoop 						; and loop round
		;
CallZTemp0:
		jmp 	(zTemp0)
		;
		;		Got something (type in A, data in XY, that is not a token)
		;		Could be a procedure invocation, variable, 
		;		unknown identifier,string or constant.
		;
CompileNotToken:
		.byte 	$FF
		;
		;		Exit the compiler.
		;
CompileTerminate:		
		ldx 	stackTemp 							; restore the stack pointer
		txs
		jsr 	StateRestore 						; restore ZPage and Exit.
		rts

