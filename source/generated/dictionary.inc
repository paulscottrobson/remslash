SystemDictionary:
	.byte 6 ; *** $ ***
	.byte $81
	.byte $80,$00,$00
	.byte $a4

	.byte 6 ; *** & ***
	.byte $81
	.byte $81,$00,$00
	.byte $a6

	.byte 6 ; *** * ***
	.byte $81
	.byte $82,$00,$00
	.byte $aa

	.byte 6 ; *** + ***
	.byte $81
	.byte $83,$00,$00
	.byte $ab

	.byte 7 ; *** ++ ***
	.byte $81
	.byte $84,$00,$00
	.byte $2b,$ab

	.byte 6 ; *** - ***
	.byte $81
	.byte $85,$00,$00
	.byte $ad

	.byte 7 ; *** -- ***
	.byte $81
	.byte $86,$00,$00
	.byte $2d,$ad

	.byte 6 ; *** / ***
	.byte $81
	.byte $87,$00,$00
	.byte $af

	.byte 6 ; *** : ***
	.byte $81
	.byte $88,$00,$00
	.byte $ba

	.byte 7 ; *** << ***
	.byte $81
	.byte $89,$00,$00
	.byte $3c,$bc

	.byte 7 ; *** <> ***
	.byte $81
	.byte $8a,$00,$00
	.byte $3c,$be

	.byte 6 ; *** = ***
	.byte $81
	.byte $8b,$00,$00
	.byte $bd

	.byte 6 ; *** > ***
	.byte $81
	.byte $8c,$00,$00
	.byte $be

	.byte 7 ; *** >= ***
	.byte $81
	.byte $8d,$00,$00
	.byte $3e,$bd

	.byte 7 ; *** >> ***
	.byte $81
	.byte $8e,$00,$00
	.byte $3e,$be

	.byte 9 ; *** BYTE ***
	.byte $81
	.byte $8f,$00,$00
	.byte $42,$59,$54,$c5

	.byte 9 ; *** ELSE ***
	.byte $81
	.byte $90,$00,$00
	.byte $45,$4c,$53,$c5

	.byte 10 ; *** ENDIF ***
	.byte $81
	.byte $91,$00,$00
	.byte $45,$4e,$44,$49,$c6

	.byte 7 ; *** IF ***
	.byte $81
	.byte $92,$00,$00
	.byte $49,$c6

	.byte 11 ; *** INLINE ***
	.byte $81
	.byte $93,$00,$00
	.byte $49,$4e,$4c,$49,$4e,$c5

	.byte 11 ; *** REPEAT ***
	.byte $81
	.byte $94,$00,$00
	.byte $52,$45,$50,$45,$41,$d4

	.byte 9 ; *** TEND ***
	.byte $81
	.byte $95,$00,$00
	.byte $54,$45,$4e,$c4

	.byte 10 ; *** TIMES ***
	.byte $81
	.byte $96,$00,$00
	.byte $54,$49,$4d,$45,$d3

	.byte 10 ; *** UNTIL ***
	.byte $81
	.byte $97,$00,$00
	.byte $55,$4e,$54,$49,$cc

	.byte 9 ; *** WEND ***
	.byte $81
	.byte $98,$00,$00
	.byte $57,$45,$4e,$c4

	.byte 10 ; *** WHILE ***
	.byte $81
	.byte $99,$00,$00
	.byte $57,$48,$49,$4c,$c5

	.byte 9 ; *** WORD ***
	.byte $81
	.byte $9a,$00,$00
	.byte $57,$4f,$52,$c4

	.byte $00
