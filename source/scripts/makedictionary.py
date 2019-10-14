# ******************************************************************************
# ******************************************************************************
#
#		Name : 		makedictionary.py
#		Purpose : 	Creates a default dictionary
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Created : 	14th October 2019
#
# ******************************************************************************
# ******************************************************************************

import re,os,sys
#
#		Get the keyword list. Note, not all of these are in use !
#
keywords = """
	byte word 
	if else endif
	repeat until
	while wend
	times tend
	case when endcase
	inline class debug
	ref library const
	+ - * : & ^ /
	++ -- << >> > = >= <> 
""".replace("\t"," ").replace("\n"," ").upper().split()
keywords.sort()
#
#		Create the dictionary
#
h = open("generated/dictionary.inc","w")
h.write("StandardDictionary:\n")
for i in range(0,len(keywords)):
	h.write("\t.byte {0} ; *** {1} ***\n".format(len(keywords[i])+5,keywords[i]))
	h.write("\t.byte $01\n")
	h.write("\t.byte ${0:02x},$00,$00\n".format(i+0x40))
	name = [ord(x) for x in keywords[i].upper()]
	name[-1] |= 0x80
	h.write("\t.byte {0}\n\n".format(",".join(["${0:02x}".format(x) for x in name])))
h.write("\t.byte $00\n")
#
#		Create the constants
#
h = open("generated/tokens.inc","w")
for i in range(0,len(keywords)):
	name = keywords[i].upper()
	name = name.replace("$","DOLLAR").replace("&","AMP").replace("*","STAR")
	name = name.replace("+","PLUS").replace("-","MINUS").replace(">","GREATER")
	name = name.replace("=","EQUAL").replace("<","LESS").replace(":","COLON")
	name = name.replace("/","SLASH").replace("^","HAT").replace("","")
	assert re.match("^[A-Z\\_]+$",name) is not None,name
	h.write("KWD_{0:24} = ${1:02x}; {2}\n".format(name,i+0x40,keywords[i]))
