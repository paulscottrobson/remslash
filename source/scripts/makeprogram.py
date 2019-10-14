# ******************************************************************************
# ******************************************************************************
#
#		Name : 		makeprogram.py
#		Purpose : 	Creates a BASIC program for dotREM to run.
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Created : 	14th October 2019
#
# ******************************************************************************
# ******************************************************************************

class BasicProgram(object):
	def __init__(self,loadAddress = 0x801):
		self.code = []
		self.lineNumber = 1000
		self.loadAddress = loadAddress
		self.addLine(chr(0x99)+chr(199)+"(14)")				# PRINT CHR$(14)
		self.addLine(chr(0x9E)+str(0xA000))					# SYS 40960
	#
	def add(self,line):
		self.addLine("// "+line.upper().strip())			# // <contents>
	#
	def addLine(self,line):
		self.appendWord(self.loadAddress+len(self.code)+len(line)+5)
		self.appendWord(self.lineNumber)
		self.code += [ord(x) for x in line]
		self.code.append(0)
		self.lineNumber += 10
	#
	def appendWord(self,n):
		self.code.append(n & 0xFF)
		self.code.append(n >> 8)
	#
	def complete(self):
		self.appendWord(0)

	def writeProgram(self):
		h = open("generated/test.prg","wb")
		h.write(bytes([self.loadAddress & 0xFF,self.loadAddress >> 8]))
		h.write(bytes(self.code))
		h.close()

bp = BasicProgram()
#bp.add('word new.var@$142 byte var@$143')
#bp.add('byte n2@$FEEE byte n33 word a byte b byte b')
bp.add('byte b word w1')
bp.add('byte str.len("')

bp.complete()
bp.writeProgram()
