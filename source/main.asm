; ******************************************************************************
; ******************************************************************************
;
;		Name : 		main.asm
;		Purpose : 	Compiler Main Program
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th October 2019
;
; ******************************************************************************
; ******************************************************************************

SourceCode = $801
UserDictionary = $B000
UserCode = $B800
VariableMemory = $0600

		.include 	"data.asm"
		.include 	"macros.inc"
		.include 	"generated/tokens.inc"

		* = $A000
		jmp 	CompileRun

CompileRun:
		jsr 	LoadBasicCode 	
		jsr 	Compiler
		rts

		.include 	"analysis/element.asm"		; element extraction manager.
		.include 	"analysis/findtoken.asm"	; scan through code looking for tokens.
		.include 	"compiler/compiler.asm"		; compiler main
		.include 	"compiler/error.asm"		; error handling
		.include 	"dictionary/dictionary.asm"	; dictionary code.
		.include 	"generated/dictionary.inc"	; system dictionary.
		.include 	"generated/vectors.inc"		; keyword handler vectors.
		.include 	"handlers/byteword.asm"		; byte/word handlers.
		.include 	"utility/constant.asm" 		; ASCII -> Integer conversion.			
		.include 	"utility/state.asm"			; state save/load.
		.include 	"utility/tostring.asm"		; integer to string.
		.include 	"utility/loadcode.asm" 		; last so it changes the bare minimum.	
EndCode:		
