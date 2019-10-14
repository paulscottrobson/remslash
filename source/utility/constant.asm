; ******************************************************************************
; ******************************************************************************
;
;		Name : 		constant.asm
;		Purpose : 	Try to convert buffer to a constant.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	13th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;			Convert Buffer to Integer in YX. CS = Okay, CC = Failed.
;
; ******************************************************************************

ConstantToInteger:
		ldy 	#16 						; base to use.
		ldx 	#1 							; character offset.
		;
		lda 	tokenBuffer 				; first character
		cmp 	#"&"						; is it hexadecimal
		beq 	_CTIConvert 				; convert from character 1, base 16.
		;
		dex 								; from character 0
		ldy 	#10 						; base 10.
		cmp 	#"-"						; first char is unary minus ?
		bne 	_CTIConvert 				; no, convert as +ve decimal
		;
		inx 								; skip the minus
		jsr 	_CTIConvert 				; convert the unsigned part.
		bcc 	_CTIExit 					; failed
		;
		txa 								; 1's complement YX
		eor 	#$FF
		tax
		tya
		eor 	#$FF
		tay
		;
		inx 								; +1 to make it negative
		sec
		bne 	_CTIExit
		iny
_CTIExit:
		rts		
;
;		Offset in token buffer in X, base to use in Y.
;
_CTIConvert:		
		sty 	zTemp1 						; save base in zTemp1
		lda 	tokenBuffer,x 				; get first character
		beq 	_CTIFail 					; if zero, then it has failed anyway.
		;
		stz 	zTemp0 						; clear the result.
		stz 	zTemp0+1
		;
_CTILoop:
		lda 	zTemp0 						; copy current to zTemp2
		sta 	zTemp2
		lda 	zTemp0+1
		sta 	zTemp2+1
		stz 	zTemp0 						; clear result
		stz 	zTemp0+1
		ldy 	zTemp1 						; Y contains the base.
		;
_CTIMultiply:
		tya 								; shift Y right into carry.
		lsr 	a
		tay
		bcc 	_CTINoAdd 					; skip if CC, e.g. LSB was zero
		;
		clc
		lda 	zTemp2 						; add zTemp2 into zTemp0
		adc 	zTemp0
		sta 	zTemp0
		lda 	zTemp2+1
		adc 	zTemp0+1
		sta 	zTemp0+1
		;
_CTINoAdd:
		asl 	zTemp2 						; shift zTemp2 left e.g. x 2
		rol 	zTemp2+1
		cpy 	#0 							; multiply finished ?
		bne 	_CTIMultiply
		;
		lda 	tokenBuffer,x 				; check in range 0-9 A-F
		and 	#$7F 						; remove End of Token bit if set
		cmp 	#"0"
		bcc 	_CTIFail
		cmp 	#"9"+1
		bcc 	_CTIOkay
		cmp 	#"A"
		bcc 	_CTIFail
		cmp 	#"F"
		bcs 	_CTIFail
		;
		sec 								; hex adjust
		sbc 	#7
_CTIOkay:
		sec
		sbc 	#48
		cmp 	zTemp1  					; if >= base then fail.
		bcs 	_CTIFail
		;
		cld
		adc 	zTemp0 						; add into the current value		
		sta 	zTemp0
		bcc 	_CTINoCarry
		inc 	zTemp0+1
_CTINoCarry:
		;
		inx 								; get next in buffer
		lda 	tokenBuffer,x 		
		bne 	_CTILoop 					
		;
		ldx 	zTemp0 						; return result
		ldy 	zTemp0+1
		sec
		rts

_CTIFail:		
		clc
		rts
