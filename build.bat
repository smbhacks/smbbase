@echo off
ca65 --cpu 6502X -l output.lst -g main.asm -o output.o
ld65 -m map.txt -C main.cfg output.o -o output.nes --dbgfile output.dbg
pause