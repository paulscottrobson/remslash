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

		.include 	"data.asm"
		.include 	"macros.inc"

		* = $A000
		jmp 	CompileRun

CompileRun:
		jsr 	LoadBasicCode 	
		jsr 	Compiler
		rts

		.include 	"analysis/element.asm"		; element extraction manager.
		.include 	"analysis/findtoken.asm"	; scan through code looking for tokens.
		.include 	"compiler/compiler.asm"		; compiler main
		.include 	"utility/state.asm"			; state save/load.
		.include 	"utility/loadcode.asm" 		; last so it changes the bare minimum.				
EndCode:		
