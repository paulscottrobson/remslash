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
#		Get the keyword list.
#
keywords = """
	byte word 
	if else endif
	repeat until
	while wend
	times tend
	inline
	+ - * : &
	$
	++ -- << >> > = >= <> /
""".replace("\t"," ").replace("\n"," ").upper().split()
keywords.sort()
#
#		Create the dictionary
#

#
#		Create the constants
#
h = open("generated/tokens.inc","w")
for i in range(0,len(keywords)):
	name = keywords[i].upper()
	name = name.replace("$","DOLLAR").replace("&","AMP").replace("*","STAR")
	name = name.replace("+","PLUS").replace("-","MINUS").replace(">","GREATER")
	name = name.replace("=","EQUAL").replace("<","LESS").replace(":","COLON")
	name = name.replace("/","SLASH").replace("","").replace("","")
	assert re.match("^[A-Z\\_]+$",name) is not None,name
	h.write("KWD_{0:24} = ${1:02x}; {2}\n".format(name,i+0x80,keywords[i]))
