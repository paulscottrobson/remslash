
python scripts/makeprogram.py
64tass -Wall -q -c main.asm -o remslash.prg -L remslash.lst
if [ $? -eq 0 ]; then
	../../x16-emulator/x16emu -prg remslash.prg -run -debug -scale 2
fi